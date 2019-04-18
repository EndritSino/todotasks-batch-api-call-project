# Create Tasks attached to an arbitrary case, via an API(utilise scheduled Batch classes)

    The idea is that you should create:

    An Account
    An Opportunity related to the account
    A Case related to the Account

    Now you have an open web service with URL = https://jsonplaceholder.typicode.com/todos

##Requirement 1:

    This is a list of todos composed of < userId, Id, title, completed >, you should create a batch job that:

    1. Will be scheduled every night at whatever time you prefer
    2. Will call the web service and will create tasks in this particular case that are mapped to the todos retrieved from the web service like:

    userId => a user ( that you previously created in salesforce )
    id => save it in the task somehow , preferably that could be retrieved or queried easily.  If you have any good suggestions on where to save it, that’s even better
    title => subject
    completed => status ; the values must be mapped like : completed-> true, in progress -> false

    3. The batch job must have a test class that tests the validity of the solution.

    Suggestion:
    Make the service smart, everytime that you check the webservice don't recreate the task, check which task are already there.

##Requirement 2:

    For every task in a case marked as “completed” the related opportunity value (amount) must increase by 1%

## Issues

###1. How was achieve not inserting a task twice?

    In the task object there is custom field used as an external Id, named 'External Id'. This field is marked as an external Id,
    and furthermore also as a unique one.

    The Batch in the other hand possesses a logic that inserts tries to insert all the tasks that are fetched from the API, allowing
    partial success.

    These 2 features of the implementation allow us to make sure that a task, with a particular external id, is not entered twice.

    Note:

    This strategy doesn't work if the external API doesn't guarantee that the all the tasks for different owners, have different external ids.

    Also, if the external id is empty from the records fetched from the API, might result in potential duplicates.

###2. Usage of the batch class instead of a @future for example:

    The batch class usage in this implementation may not be the appropriate solution to go with as the business logic itself is bound
    primarily to the external data coming from the web service rather then from data within Salesforce.

    To better explain when would be the case when the batch would've made sense:
    If we would be interested to create tasks coming from an external system only for a specific set of records within Salesforce.
    Say create tasks for Cases with an overdue date of 1 week. In this case the batch would've made sense as we would start the
    business logic by defining this records in the scope of the batch job and then by invoking a callout to the external service.

