$hex = "0x"+"{0:x}" -f  $task.LastTaskResult

   $errorMsg = $(switch($hex){

        '0x0'	{'The operation completed successfully.'}
        '0x1'	{'Incorrect function called or unknown function called.'}
        '0x2'	{'File not found.'}
        '0xa'	{'The environment is incorrect.'}
        '0x41300'	{'Task is ready to run at its next scheduled time.'}
        '0x41301'	{'Task is currently running.'}
        '0x41302'	{'Task is disabled.'}
        '0x41303'	{'Task has not yet run.'}
        '0x41304'	{'There are no more runs scheduled for this task.'}
        '0x41305'	{'One or more of the properties that are needed to run this task on a schedule have not been set.'}
        '0x41306'	{'Task is terminated.'}
        '0x41307'	{'Either the task has no triggers or the existing triggers are disabled or not set.'}
        '0x41308'	{'Event triggers do not have set run times.'}
        '0x41309'	{'A tasks trigger is not found.'}
        '0x8004130A'	{'One or more of the properties required to run this task have not been set.'}
        '0x8004130B'	{'There is no running instance of the task.'}
        '0x8004130C'	{'The Task Scheduler service is not installed on this computer.'}
        '0x8004130E'	{'The task object could not be opened.'}
        '0x8004130F'	{'Credentials became corrupted (*)'}
        '0x8004131F'	{'An instance of this task is already running.'}
        '0x80070002'	{'Basically something like file not available (2147942402)'}
        '0x800704DD'	{'The service is not available (is Run only when an user is logged on checked?)'}
        '0xC000013A'	{'The application terminated as a result of a CTRL+C.'}
        '0xC06D007E'	{'Unknown software exception'}
        '0x80041310'	{'Unable to establish existence of the account specified.'}
        '0x80041311'	{'Corruption was detected in the Task Scheduler security database; the database has been reset.'}
        '0x80041312'	{'Task Scheduler security services are available only on Windows NT.'}
        '0x80041313'	{'The task object version is either unsupported or invalid.'}
        '0x80041314'	{'The task has been configured with an unsupported combination of account settings and run time options.'}
        '0x80041315'	{'The Task Scheduler Service is not running.'}
        '0x80041316'	{'The task XML contains an unexpected node.'}
        '0x80041317'	{'The task XML contains an element or attribute from an unexpected namespace.'}
        '0x80041318'	{'The task XML contains a value which is incorrectly formatted or out of range.'}
        '0x80041319'	{'The task XML is missing a required element or attribute.'}
        '0x8004131A'	{'The task XML is malformed.'}
        '0x0004131B'	{'The task is registered, but not all specified triggers will start the task.'}
        '0x0004131C'	{'The task is registered, but may fail to start. Batch logon privilege needs to be enabled for the task principal.'}
        '0x8004131D'	{'The task XML contains too many nodes of the same type.'}
        '0x8004131E'	{'The task cannot be started after the trigger end boundary.'}
        '0x8004131F'	{'An instance of this task is already running.'}
        '0x80041320'	{'The task will not run because the user is not logged on.'}
        '0x80041321'	{'The task image is corrupt or has been tampered with.'}
        '0x80041322'	{'The Task Scheduler service is not available.'}
        '0x80041323'	{'The Task Scheduler service is too busy to handle your request. Please try again later.'}
        '0x80041324'	{'The Task Scheduler service attempted to run the task, but the task did not run due to one of the constraints in the task definition.'}
        '0x00041325'	{'The Task Scheduler service has asked the task to run.'}
        '0x80041326'	{'The task is disabled.'}
        '0x80041327'	{'The task has properties that are not compatible with earlier versions of Windows.'}
        '0x80041328'	{'The task settings do not allow the task to start on demand.'}
        '0xC000013A'	{'The application terminated as a result of a CTRL+C.'}

        default {'No matching error'}


    })