public class EnsembleRestCallout {

    // ── Operation identifiers ────────────────────────────────────────────────
    // Hardcoded now; replace with CustomMetadata lookup in the future.

    public static final String OP_CANCEL       = 'cancel';
    public static final String OP_SET_NEW      = 'setNew';
    public static final String OP_RESCHEDULE   = 'reschedule';
    public static final String OP_SEARCH       = 'search';
    public static final String OP_LOCK         = 'lock';
    public static final String OP_UNLOCK       = 'unlock';
    public static final String OP_REFRESH_LOCK = 'refreshLock';

    // ── REST endpoint paths ──────────────────────────────────────────────────
    // @TestVisible so unit tests can swap paths without callouts.

    @TestVisible static String CANCEL_PATH         = '/appointments/cancel';
    @TestVisible static String SET_NEW_PATH        = '/appointments?version=2';
    @TestVisible static String RESCHEDULE_NEW_PATH = '/appointments/reschedule?version=2';
    @TestVisible static String SEARCH_PATH         = '/appointments/search';
    @TestVisible static String LOCK_PATH           = '/slots/lock';
    @TestVisible static String UNLOCK_PATH         = '/slots/{0}';
    @TestVisible static String REFRESH_LOCK_PATH   = '/slots/{0}/lock';

    // ── Internal response DTO (flat AppointmentResult array) ────────────────

    private class AppointmentOpResponse {
        public ws_AppointmentNew.Result MessageResult;
        public List<ws_AppointmentNew.AppointmentResult> AppointmentResult;
    }

    // ── Public entry points ──────────────────────────────────────────────────

    /**
     * Executes a REST call to Ensemble.
     * operation — one of OP_* constants.
     * body      — the matching *Request DTO.
     * Returns the typed response object; callers cast to the expected type.
     */
    public static Object call(String operation, Object body) {
        return call(operation, body, null);
    }

    /**
     * Overload for operations that embed a path parameter in the URL
     * (OP_UNLOCK: DELETE /slots/{slotLockId}, OP_REFRESH_LOCK: PUT /slots/{slotLockId}/lock).
     */
    public static Object call(String operation, Object body, String pathParam) {
        String httpMethod;
        String path;

        switch on operation {
            when 'cancel'      { httpMethod = 'POST';   path = CANCEL_PATH; }
            when 'setNew'      { httpMethod = 'POST';   path = SET_NEW_PATH; }
            when 'reschedule'  { httpMethod = 'PUT';    path = RESCHEDULE_NEW_PATH; }
            when 'search'      { httpMethod = 'POST';   path = SEARCH_PATH; }
            when 'lock'        { httpMethod = 'POST';   path = LOCK_PATH; }
            when 'unlock'      { httpMethod = 'DELETE'; path = String.format(UNLOCK_PATH,       new List<String>{ pathParam }); }
            when 'refreshLock' { httpMethod = 'PUT';    path = String.format(REFRESH_LOCK_PATH, new List<String>{ pathParam }); }
            when else {
                LC_BackendUtils.throwEnsembleError('Unknown Ensemble operation: ' + operation);
                return null; // unreachable
            }
        }

        String serializedBody = (operation == OP_UNLOCK) ? null : JSON.serialize(body, true);
        HttpResponse res = send(httpMethod, path, serializedBody);

        if (operation == OP_CANCEL) {
            return JSON.deserialize(res.getBody(), ws_AppointmentNew.CancelAppointmentResponse.class);
        }

        if (operation == OP_SEARCH) {
            return JSON.deserialize(res.getBody(), ws_AppointmentNew.AppointmentSearchResponse.class);
        }

        if (operation == OP_LOCK) {
            return JSON.deserialize(res.getBody(), ws_AppointmentNew.LockSlotResponse.class);
        }

        if (operation == OP_UNLOCK) {
            return JSON.deserialize(res.getBody(), ws_AppointmentNew.UnLockSlotResponse.class);
        }

        if (operation == OP_REFRESH_LOCK) {
            return JSON.deserialize(res.getBody(), ws_AppointmentNew.RefreshLockSlotResponse.class);
        }

        AppointmentOpResponse parsed = (AppointmentOpResponse) JSON.deserialize(
            res.getBody(), AppointmentOpResponse.class);

        if (operation == OP_SET_NEW) {
            ws_AppointmentNew.SetAppointmentResponse out = new ws_AppointmentNew.SetAppointmentResponse();
            out.MessageResult = parsed.MessageResult;
            if (parsed.AppointmentResult != null) {
                out.AppointmentResult = new ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult();
                out.AppointmentResult.AppointmentResult = parsed.AppointmentResult;
            }
            return out;
        }

        // OP_RESCHEDULE
        ws_AppointmentNew.RescheduleAppointmentResponse out = new ws_AppointmentNew.RescheduleAppointmentResponse();
        out.MessageResult = parsed.MessageResult;
        if (parsed.AppointmentResult != null) {
            out.AppointmentResult = new ws_AppointmentNew.ArrayOfAppointmentResultAppointmentResult();
            out.AppointmentResult.AppointmentResult = parsed.AppointmentResult;
        }
        return out;
    }

    // ── HTTP core ────────────────────────────────────────────────────────────

    private static HttpResponse send(String method, String path, String body) {
        ENV__c env = ENV__c.getInstance();
        List<EnsembleSystem__mdt> creds = [SELECT UserName__c, Password__c FROM EnsembleSystem__mdt LIMIT 1];
        if (creds.isEmpty()) {
            LC_BackendUtils.throwEnsembleError('EnsembleSystem__mdt configuration is missing');
        }

        String endpoint = 'callout:Ensemble_AssutaMain_' + env.Env_value__c + path;

        HttpRequest req = new HttpRequest();
        req.setEndpoint(endpoint);
        req.setMethod(method);
        req.setHeader('Content-Type', 'application/json');
        req.setHeader('Accept', 'application/json');
        req.setHeader('Authorization', 'Basic ' + EncodingUtil.base64Encode(
            Blob.valueOf(creds[0].UserName__c + ':' + creds[0].Password__c)));
        if (body != null) { req.setBody(body); }
        req.setTimeout(120000);

        System.debug('EnsembleRestCallout ' + method + ' ' + endpoint);
        System.debug('EnsembleRestCallout body: ' + req.getBody());

        try {
            HttpResponse res = new Http().send(req);
            System.debug('EnsembleRestCallout status=' + res.getStatusCode() + ' body=' + res.getBody());
            if (res.getStatusCode() < 200 || res.getStatusCode() >= 300) {
                LC_BackendUtils.throwEnsembleError('HTTP ' + res.getStatusCode() + ' from Ensemble: ' + res.getBody());
            }
            return res;
        } catch (System.CalloutException e) {
            LC_BackendUtils.throwEnsembleError(e.getMessage());
            return null; // unreachable — throwEnsembleError always throws
        }
    }
}
