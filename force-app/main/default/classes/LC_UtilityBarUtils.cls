//Test: LC_UtilityBarTest
public with sharing class LC_UtilityBarUtils {
    
    public static final String API_PATH_SERVICE = '/services/data';
    public static final String API_VERSION_61 = '/v61.0';
    public static final String API_PATH_DASHBOARDS = '/analytics/dashboards';
    public static final String API_PATH_STATUS = '/status';
    public static final String API_NAMED_CRED_SF = 'callout:Salesforce_API';
    
    public static final String SUPPORT_PROFILES_DASHBOARD_REFRESH = System.Label.Dashboard_Refreshable_Profiles;
    public static final String MSG_DASBOARD_UP_TO_DATE = 'Dashboard is up to date';

    public static final Integer DEFAULT_REFRESH_TIME = 60;
    public static final Integer MILLISECONDS = 1000;

    public static String buildDashboardsURL(String dashboardId) {
        return API_NAMED_CRED_SF + API_PATH_SERVICE + API_VERSION_61 + API_PATH_DASHBOARDS + '/' + dashboardId;
    }

    public static String buildDashboardsStatusURL(String dashboardId) {
        return buildDashboardsURL(dashboardId) + API_PATH_STATUS;
    }

    public static User obtainUser(String userId) {
        List<User> users = [SELECT Id, ProfileId, Profile.Name FROM User WHERE Id = :userId LIMIT 1];

        return (users.isEmpty()) ? null : users.get(0);
    }

    public static List<String> getSupportProfilesForDashboardRefresh() {
        List<String> result = new List<String>(); 

        if (String.isBlank(SUPPORT_PROFILES_DASHBOARD_REFRESH)) {
            return result;
        }

        for (String profileName_i : SUPPORT_PROFILES_DASHBOARD_REFRESH.trim().split(',')) {
            result.add(profileName_i.trim());
        }
        return result;
    }
}