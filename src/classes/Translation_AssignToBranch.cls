public with sharing class Translation_AssignToBranch {
	private Translation__c[] sObjectNewList;
	
    public Translation_AssignToBranch(Translation__c[] sObjectOldList, Translation__c[] sObjectNewList) {
    	this.sObjectNewList = sObjectNewList;
    }
    
    public void execute() {
        Map<Id, User> userMap = new Map<Id, User>([SELECT Name,
                                                    UserRoleId
                                                    FROM User]); 
        Map<Id, UserRole> userRoleMap = new Map<Id, UserRole>([SELECT 
                                                                DeveloperName 
                                                                FROM UserRole]);                                        
        system.debug(userMap);
        system.debug(userRoleMap);
        
        for (Translation__c translation : sObjectNewList) {
        	if (userMap.get(translation.OwnerId).UserRoleId == null) {
        		continue;
        	}
        	String userRoleName = userRoleMap.get(userMap.get(translation.OwnerId).UserRoleId).DeveloperName;
            String branchId = ReflexSettings.getSettingValue('ROLE_TO_BRANCH_' + userRoleName);
            if(branchId != null) {
            	translation.Branch__c = branchId;
            }    
        }
    }
}