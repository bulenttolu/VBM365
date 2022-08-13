##############################################################
#  BULENT TOLU 
#  Rev: 1.0    
#  Please use it with your own risk, Not tested in production
#  For VBM365 V6, REST API needs to be enabled. 
#  Searches VBM 365 Audit Logs via RESTAPI
##############################################################

###### General  Setup ######
############################################################
$veeamUsername="username"
$veeamPassword="password"
$veeamRestServer="https://ip"
$veeamRestPort="4443" 
$timeStart= (Get-Date).AddDays(-7) #Searched last x (7) days
#############################################################

###### Workaround for self-signed certificates ###############
add-type @"
    using System.Net;
    using System.Security.Cryptography.X509Certificates;
    public class TrustAllCertsPolicy : ICertificatePolicy {
        public bool CheckValidationResult(
            ServicePoint srvPoint, X509Certificate certificate,
            WebRequest request, int certificateProblem) {
            return true;
        }
    }
"@
[System.Net.ServicePointManager]::CertificatePolicy = New-Object TrustAllCertsPolicy
#################################################################

###### RESTAPI LOGIN & GET TOKEN/BEARER ########################
$uriToken = $veeamRestServer+":"+$veeamRestPort+"/v6/token"
$requestBody = "grant_type=password&username=$veeamUsername&password=$veeamPassword"
$response = Invoke-RestMethod -Uri $uriToken -Method Post -Body $requestBody
$veeamBearer = $response.access_token

###### Building HEADERS with Token  ############################
$headers = @{
    Authorization = "Bearer $veeamBearer"
    Accept = "application/json"
}

###### Organizations list ########################
$veeamOrgsUrl=$veeamRestServer+":"+$veeamRestPort+"/v6/Organizations"
$veeamOrgs = Invoke-RestMethod -Uri $veeamOrgsUrl -Headers $headers 


###### SEARCH RESTORE SESSIONS AND EVENT DETAILS ############
$Output = @()

# Retrieve Restore Sessions
$veeamRestoreURL=$veeamRestServer+":"+$veeamRestPort+"/v6/RestoreSessions?starttimeFrom="+$timestart
$veeamRestoreSessions = Invoke-RestMethod -Uri $veeamRestoreURL -Headers $headers

# foreach Restore Session found; 
foreach ($veeamRestoreSession in $veeamRestoreSessions.results)
{
    ## For each Restore Session, Get its Events and Details
    $veeamRestoreEventsUrl=$veeamRestServer+":"+$veeamRestPort+"/v6/RestoreSessions/"+$veeamRestoreSession.id+"/Events?offset=0"
    $veeamRestoreSessionEventDetails = Invoke-RestMethod -Uri $veeamRestoreEventsUrl -Headers $headers

    ## For Each event Found for a "defined session", get event details and collect results into object
    foreach ($veeamRestoreSessionEventDetail in $veeamRestoreSessionEventDetails.results)
    {
        # General Restore Session Details being searched 
        $Props_Session = @{
            "SessionID" = $veeamRestoreSession.id  
                    "Initiated By" = $veeamRestoreSession.initiatedBy
                    "Name" = $veeamRestoreSession.name
                    "org" = $veeamRestoreSession.organization
                    "type" = $veeamRestoreSession.type
                    "creationTime" = $veeamRestoreSession.creationTime
                    "endTime" = $veeamRestoreSession.endTime
                    "state" = $veeamRestoreSession.state
                    "result" = $veeamRestoreSession.result
                    "details" = $veeamRestoreSession.details
                    "scopeName" = $veeamRestoreSession.scopeName
                    "clientHost" = $veeamRestoreSession.clientHost
            }

        # Session Start and End Events (Type None)
        if ($veeamRestoreSessionEventDetail.type -eq "None") 
            {
           
            #EventDetails
            $Props_StartEndEventDetails = @{
                "itemSizeBytes"= $veeamRestoreSessionEventDetail.itemSizeBytes
                "id"= $veeamRestoreSessionEventDetail.id
                "eventtype"= $veeamRestoreSessionEventDetail.type
                "status"= $veeamRestoreSessionEventDetail.status
                "StartTime"= $veeamRestoreSessionEventDetail.StartTime
                "eventEndTime"= $veeamRestoreSessionEventDetail.EndTime
                "duration"= $veeamRestoreSessionEventDetail.duration
                "title"= $veeamRestoreSessionEventDetail.title
                "Message"= $veeamRestoreSessionEventDetail.Message
                "order"= $veeamRestoreSessionEventDetail.order
            }
            $eventOutput = $Props_Session + $Props_StartEndEventDetails 
        
        }
        #Session Event Details for others 
        else {
                      
                #EventDetails
                $Props_EventDetails = @{
                    "itemname"= $veeamRestoreSessionEventDetail.itemName
                    "itemType"= $veeamRestoreSessionEventDetail.itemType
                    "itemSizeBytes"= $veeamRestoreSessionEventDetail.itemSizeBytes
                    "source"= $veeamRestoreSessionEventDetail.source
                    "target"= $veeamRestoreSessionEventDetail.target
                    "id"= $veeamRestoreSessionEventDetail.id
                    "eventtype"= $veeamRestoreSessionEventDetail.type
                    "status"= $veeamRestoreSessionEventDetail.status
                    "StartTime"= $veeamRestoreSessionEventDetail.StartTime
                    "eventEndTime"= $veeamRestoreSessionEventDetail.EndTime
                    "duration"= $veeamRestoreSessionEventDetail.duration
                    "title"= $veeamRestoreSessionEventDetail.title
                    "Message"= $veeamRestoreSessionEventDetail.Message
                    "order"= $veeamRestoreSessionEventDetail.order
                    
                }

            $eventOutput = $Props_Session + $Props_EventDetails
        }
        
        #Collect into custom object
        $Output += New-Object PSObject -Property $eventOutput

        }
    }

#####  OUTPUT AS NEEDED by selecting props #####
##################################################

# OUT-GRIDVIEW
$Output | select Org, SessionID, "initiated by", Name,type,creationTime,details,clientHost,itemname,itemtype,source,
target,id, eventtype,message,order | Out-GridView 

# HTML OUTPUT 
# $Output | select Org, SessionID, "initiated by", Name,type,creationTime,details,clientHost,itemname,itemtype,source,
# target,id, eventtype,message,order | ConvertTo-Html | out-file C:\Users\Administrator\Desktop\html1.html 
# Invoke-Item C:\Users\Administrator\Desktop\html1.html 

# Console OUTPUT 
# $Output | select Org, SessionID, "initiated by", Name,type,creationTime,details,clientHost,itemname,itemtype,source,
# target,id, eventtype,message,order | ft




