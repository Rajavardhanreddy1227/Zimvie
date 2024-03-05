global class B2B_AccountEnablementBatchSchedule implements Schedulable {
    global void execute(SchedulableContext sc) {
        B2B_AccountEnablementBatch batch = new B2B_AccountEnablementBatch(null);
        Database.executeBatch(batch);
    }
}