# Windows Task Scheduler Event Codes
I'm trying to make sense of these codes that were obviously created from multiple teams with no interaction with each other.  What is it that _I_ want to know?  Did the Task fail to start or did it fail to complete with a zero code? Simple stuff.

## Failure of Task to Launch
- 130 Launch condition not met, service busy
- 112 Launch condition not met, network unavailable
- 128 Launch condition not met, beyond end time 
- 130 Launch condition not met, service busy
- 131 Launch condition not met, quota exceeded                (Task Quota)
- 132 Launch condition warning, quota approaching             (Task Quota)
- 133 Launch condition not met, quota exceeded                (Engine quota)
- 134 Launch condition warning, quota approaching             (Engine quota)
- 135 Launch condition not met, machine not idle
- 326 Launch condition not met, computer on batteries
- 332 Launch condition not met, user not logged-on
- 333 Launch condition not met, session is RemoteApp Session
- 334 Launch condition not met, session is a Worker Session 
- 306 Engine failed to receive the task                      
- 322 Launch request ignored, instance already running 
- 324 Launch request queued, instance already running
- 203 Action failed to start
- 146 Task loading at service startup failed
- 151 Task Scheduler failed to instantiate task at service startup. 
- 105 Impersonation failure 
- 104 Logon failure
- 325 Launch request queued
- 204 Task failed to start on event 
- 205 Task failed to start on event pattern match  
- 305 Task failed to be sent to engine
- 153 Missed task start rejected 
## Failure of Task to Complete
- 202 Action failed
- 303 Task engine shut down due to error 
- 320 Task Engine received message to stop task
- 323 Launch request acknowledged, current instance stopped
- 327 Task stopping due to  switching to batteries                        [SIC]
- 328 Task stopping due to computer not idle
- 329 Task stopping due to timeout reached
- 330 Task stopping due to user request
- 331 Task failed to stop on timeout                       (Task may be hosed????)
- 111 Task terminated
- 303 Task engine shut down due to error
## Task Will No Longer Launch
- 311 Task Engine failed to start    
- 142 Task disabled
- 303 Task engine shut down due to error  
- 149 Task is using a combination of properties that is incompatible with the scheduling engine
- 141 Task registration deleted  
- 150 Task registration on event failed 
## Flag Watch for Launch of Task
- 319 Task Engine received message to start task             Expect to see task started
- 304 Task sent to engine
- 325 Launch request queued               
- 324 Launch request queued, instance already running 
## Task Execution Environment Corrupt
 - 309 Engine orphaned
 - 401 Service failed to start 
 - 402 Service is shutting down
 - 403 Service critical error           
 - 404 Service RPC error                
 - 405 Service COM error        
 - 315 Service Engine connection failure         
 - 406 Cred store initialization error  
 - 407 LSA initialization error         
 - 408 Idle detection error                                Specifically Idle triggers
 - 410 Wakeup timer error     
 - 719 TaskScheduler Operational log was disabled   
 - 998 Method Failure      
 - 303 Task engine shut down due to error                    
## Task May not Function when Launched
- 116 Task registered without credentials
- 113 Task registered without some triggers
- 414 Task Misconfiguration
- 115 Task update or deletion error                       (TransactionRollbackFailure)
## Failure to Complete Re-launch
- 114 Missed task started
- 126 Task restarted on failure (Failed Task)
- 127 Task restarted on failure (Rejected Task)
- 148 Task image recovering failed after OS migration 
## May Effect Task Function
- 411 Service signaled time change
- 409 Time change notification error   
