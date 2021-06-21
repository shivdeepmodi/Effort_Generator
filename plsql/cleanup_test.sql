delete TASK_SUBTASK_DAILY    where WORK_TASK like 'TEST_TASK%';
delete TASK_SUBTASK          where WORK_TASK like 'TEST_TASK%';
delete TASK_MAIN             where WORK_TASK like 'TEST_TASK%';  
commit;