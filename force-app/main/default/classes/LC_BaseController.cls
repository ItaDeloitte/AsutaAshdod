// Test: LC_BaseControllerTest
public without sharing class LC_BaseController {

    public class LC_BaseControllerException extends Exception {}

    // params map: param name => param value
    @AuraEnabled
    public static Response execute(String controllerName, Map<String, Object> params) {
        System.debug('params: '+ params);
        try {
            System.Type type = Type.forName(controllerName);
            if (type == null) {
                throw new LC_BaseControllerException(controllerName + ' isn\'t a valid controller name.');
            }

            Object instance = type.newInstance();
            if (!(instance instanceof ILCController)) {
                throw new LC_BaseControllerException(controllerName + ' isn\'t an instance of an interface.');
            }

            ILCController executer = (ILCController) instance;
            return executer.executeAction(params);
        } catch (Exception e) {
            insert LogSettingService.getInstance().prepareLog('LC_BaseController', e);
            System.debug('Error on line :' + e.getLineNumber() + ' stack trace ' + e.getStackTraceString() + ' message ' + e.getMessage());
            if (e instanceof System.CalloutException) {
                LC_BackendUtils.throwEnsembleError(e.getMessage());
            }
            return new Response(e);
        }

    }
}