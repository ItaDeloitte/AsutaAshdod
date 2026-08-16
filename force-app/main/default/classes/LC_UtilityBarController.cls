//Test: LC_UtilityBarTest
public with sharing class LC_UtilityBarController implements ILCController {

    public class LC_UtilityBarException extends Exception {}
    
    public Response executeAction(Map<String, Object> params) {
        String actionName = (String) params.get('actionName');

        switch on actionName {
            when 'refreshDashboard' {
                return this.refreshDashboard(
                    (String) params.get('dashboardId'),
                    (Decimal) params.get('refreshTime')
                );
            }
            when 'isUserCanRefreshDashboard' {
                return this.isUserCanRefreshDashboard();
            }
            when else {
                throw new LC_UtilityBarException('UNKNOWN ACTION: ' + actionName);
            }
        }
    }

    private Response refreshDashboard(String dashboardId, Decimal refreshTime) {
        System.debug('LC_UtilityBarController.refrehDashboard...');
        return new Response(LC_UtilityBarService.getInstance().refreshDashboard(
            dashboardId, 
            Integer.valueOf(refreshTime == null ? 0 : refreshTime)));
    }

    private Response isUserCanRefreshDashboard() {
        System.debug('LC_UtilityBarController.isUserCanRefreshDashboard...');
        return(new Response(LC_UtilityBarService.getInstance().isUserCanRefreshDashboard()));
    }
}