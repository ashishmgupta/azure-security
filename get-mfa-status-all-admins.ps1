# Administrator role in Azure AD
#https://docs.microsoft.com/en-us/azure/active-directory/roles/permissions-reference

# Recommendation on conditional access : require MFA for administrators
#https://docs.microsoft.com/en-us/azure/active-directory/conditional-access/howto-conditional-access-policy-admin-mfa

Connect-MsolService
$output_file_location = "c:\temp\azure_admins_mfa_status_"+$(get-date -f yyyy-MM-dd-HH-mm-ss)+".csv"
$admin_roles = "Company Administrator","Billing Administrator","Conditional Access Administrator","Exchange Service administrator","Helpdesk administrator","Password administrator","Security administrator","Sharepoint Service administrator"

# Gets all the members in the admin roles in the roles list above
# Gets the MFA status for each member
# Appends the below data points to a file specified in the $output_file_location variable 
# DisplayName,E-mail,Role,MFA-Requirements, MFA-Methods, MFA-MethodsDefault
function get-mfs-status
{
	foreach ($roleName in $admin_roles)
	{
		write-output $roleName
		$members = Get-MsolRoleMember -RoleObjectId $(Get-MsolRole -RoleName $roleName).ObjectId
		#write-output $members
		foreach ($member in $members) 
		{
			write-output $member.EmailAddress
			
		}
		
		foreach ($member in $members) 
		{ 
		write-output $member
		Get-MsolUser -UserPrincipalName $member.EmailAddress | select DisplayName, `
		@{N='E-mail';E={$_.userPrincipalName}}, `
		@{N='Role';E={$roleName}}, `
		@{N='MFA-Requirements';E={(($_).StrongAuthenticationRequirements.state)}}, `
		@{N='MFA-Methods';E={(($_).StrongAuthenticationMethods.MethodType)}}, `
		@{N='MFA-MethodsDefault';E={($_.StrongAuthenticationMethods | where isdefault -eq 'true').MethodType}} `
		| select DisplayName,E-mail,Role, MFA-Requirements, MFA-Methods, MFA-MethodsDefault| Export-Csv $output_file_location -Append `
		}
		
	}
	
	
}

get-mfs-status
