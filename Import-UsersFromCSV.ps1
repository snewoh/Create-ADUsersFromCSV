<#
AssetDetails PowerShell module (hughowens@gmail.com) 
Copyright (C) 2017 Hugh Owens 
 
This program is free software: you can redistribute it and/or modify 
it under the terms of the GNU General Public License as published by 
the Free Software Foundation, either version 3 of the License, or 
(at your option) any later version. 
 
This program is distributed in the hope that it will be useful, 
but WITHOUT ANY WARRANTY; without even the implied warranty of 
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the 
GNU General Public License for more details. 
 
You should have received a copy of the GNU General Public License 
along with this program. If not, see <http://www.gnu.org/licenses/>. 
#>


# Load Config File if exists
[xml] $config = Get-Content "$pwd\config.xml"

if ($config) {
    $DefaultOU = $config.settings.OU
    $DefaultOffice = $config.settings.Office
    $DefaultPassword = $config.settings.password
    $DomainSuffix = $config.settings.DomainSuffix
    $UsersFile = $config.settings.UsersFile
}

$csvcontent = Import-CSV -Path $UsersFile
foreach ($user in $csvcontent){

    if([bool] (Get-ADUser -Filter {SamAccountName -eq "$($user.Username)"})){
        write-output "$($User.name) exists"
        # Skip stuff if user exists
    }else{
        [string] $FullName = ("$($user.Firstname) $($user.Lastname)")
        write-host "Adding user $Fullname with username $($user.username)"

        $Password = $(if ($User.Password){
                        (ConvertTo-SecureString $User.Password -AsPlainText -Force)
                    }else{
                        (ConvertTo-SecureString $DefaultPassword -AsPlainText -Force)
                    })
        #User doesn't exist - create new user
        $userInfo = @{
            Name = $($FullName)
            AccountPassword = $Password 
            ChangePasswordAtLogon = $false
            Company = ($user.Company)
            DisplayName = "$($user.Firstname) $($user.Lastname)"
            Enabled = $true
            MobilePhone = ($user.MobilePhone)
            OfficePhone = ($user.PhoneNumber)
            SamAccountName = ($user.Username)
            Title = ($user.Title)
            Path = $DefaultOU
            State = ($user.StateOrProvince)
            GivenName = ($user.FirstName)
            SurName = ($user.LastName)
            #UserPrincipalName = "$($user.Lastname)$($user.Firstname.Substring(0,1))@UNIFY.org.au”
            UserPrincipalName = "$($user.firstname)@$($DomainSuffix)"
            Department = ($user.Department)
            Description = ($user.Description)
            Office = ($user.Office)
            City = ($user.City)
            Fax = ($user.Fax)
            Initials = ($user.Initials)
          #  LogonName = ($user.Username)
            PostalCode = ($user.PostalCode)
            StreetAddress = ($user.StreetAddress)
            HomeDirectory = ($user.HomeDirectory)
            HomeDrive = ($user.HomeDrive)
        }
    }
    New-ADUser @userInfo -passthru -verbose
}