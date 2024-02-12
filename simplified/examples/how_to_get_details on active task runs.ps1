Get-ScheduledTaskInfo -TaskName '\FilmCab\file maintenance\back_up_unbackedup_published_media'|Select *
# LastTaskResult = 267009, 0x41301: Task is currently running
# SCHED_S_TASK_HAS_NOT_RUN 0x41303: The task has not yet run
# NumberOfMissedRuns: 0
# LastRunTime is 2/11/2024 1:34:34, but GUI shows 1:34:06!
<#
SCHED_S_TASK_READY

    0x00041300

    The task is ready to run at its next scheduled time.

SCHED_S_TASK_RUNNING

    0x00041301

    The task is currently running.

SCHED_S_TASK_DISABLED

    0x00041302

    The task will not run at the scheduled times because it has been disabled.

SCHED_S_TASK_HAS_NOT_RUN

    0x00041303

    The task has not yet run.

SCHED_S_TASK_NO_MORE_RUNS

    0x00041304

    There are no more runs scheduled for this task.

SCHED_S_TASK_NOT_SCHEDULED

    0x00041305

    One or more of the properties that are needed to run this task on a schedule have not been set.

SCHED_S_TASK_TERMINATED

    0x00041306

    The last run of the task was terminated by the user.

SCHED_S_TASK_NO_VALID_TRIGGERS

    0x00041307

    Either the task has no triggers or the existing triggers are disabled or not set.

SCHED_S_EVENT_TRIGGER

    0x00041308

    Event triggers do not have set run times.

SCHED_E_TRIGGER_NOT_FOUND

    0x80041309

    A task's trigger is not found.

SCHED_E_TASK_NOT_READY

    0x8004130A

    One or more of the properties required to run this task have not been set.

SCHED_E_TASK_NOT_RUNNING

    0x8004130B

    There is no running instance of the task.

SCHED_E_SERVICE_NOT_INSTALLED

    0x8004130C

    The Task Scheduler service is not installed on this computer.

SCHED_E_CANNOT_OPEN_TASK

    0x8004130D

    The task object could not be opened.

SCHED_E_INVALID_TASK

    0x8004130E

    The object is either an invalid task object or is not a task object.

SCHED_E_ACCOUNT_INFORMATION_NOT_SET

    0x8004130F

    No account information could be found in the Task Scheduler security database for the task indicated.

SCHED_E_ACCOUNT_NAME_NOT_FOUND

    0x80041310

    Unable to establish existence of the account specified.

SCHED_E_ACCOUNT_DBASE_CORRUPT

    0x80041311

    Corruption was detected in the Task Scheduler security database; the database has been reset.

SCHED_E_NO_SECURITY_SERVICES

    0x80041312

    Task Scheduler security services are available only on Windows NT.

SCHED_E_UNKNOWN_OBJECT_VERSION

    0x80041313

    The task object version is either unsupported or invalid.

SCHED_E_UNSUPPORTED_ACCOUNT_OPTION

    0x80041314

    The task has been configured with an unsupported combination of account settings and run time options.

SCHED_E_SERVICE_NOT_RUNNING

    0x80041315

    The Task Scheduler Service is not running.

SCHED_E_UNEXPECTEDNODE

    0x80041316

    The task XML contains an unexpected node.

SCHED_E_NAMESPACE

    0x80041317

    The task XML contains an element or attribute from an unexpected namespace.

SCHED_E_INVALIDVALUE

    0x80041318

    The task XML contains a value which is incorrectly formatted or out of range.

SCHED_E_MISSINGNODE

    0x80041319

    The task XML is missing a required element or attribute.

SCHED_E_MALFORMEDXML

    0x8004131A

    The task XML is malformed.

SCHED_S_SOME_TRIGGERS_FAILED

    0x0004131B

    The task is registered, but not all specified triggers will start the task.

SCHED_S_BATCH_LOGON_PROBLEM

    0x0004131C

    The task is registered, but may fail to start. Batch logon privilege needs to be enabled for the task principal.

SCHED_E_TOO_MANY_NODES

    0x8004131D

    The task XML contains too many nodes of the same type.

SCHED_E_PAST_END_BOUNDARY

    0x8004131E

    The task cannot be started after the trigger end boundary.

SCHED_E_ALREADY_RUNNING

    0x8004131F

    An instance of this task is already running.

SCHED_E_USER_NOT_LOGGED_ON

    0x80041320

    The task will not run because the user is not logged on.

SCHED_E_INVALID_TASK_HASH

    0x80041321

    The task image is corrupt or has been tampered with.

SCHED_E_SERVICE_NOT_AVAILABLE

    0x80041322

    The Task Scheduler service is not available.

SCHED_E_SERVICE_TOO_BUSY

    0x80041323

    The Task Scheduler service is too busy to handle your request. Please try again later.

SCHED_E_TASK_ATTEMPTED

    0x80041324

    The Task Scheduler service attempted to run the task, but the task did not run due to one of the constraints in the task definition.

SCHED_S_TASK_QUEUED

    0x00041325

    The Task Scheduler service has asked the task to run.

SCHED_E_TASK_DISABLED

    0x80041326

    The task is disabled.

SCHED_E_TASK_NOT_V1_COMPAT

    0x80041327

    The task has properties that are not compatible with earlier versions of Windows.

SCHED_E_START_ON_DEMAND

    0x80041328

    The task settings do not allow the task to start on demand.



#>