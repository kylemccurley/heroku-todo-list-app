# Heroku-Based Todo List Application
## Link: https://kyle-todos-list.herokuapp.com/lists
<img src='https://github.com/kylemccurley/heroku-todo-list-app/blob/master/Todo.png'>
<hr>
<img src='https://github.com/kylemccurley/heroku-todo-list-app/blob/master/Todo2.png'>
<hr>

### Summary of Concepts:
<ul>
  <li>State is data that persists over time.</li>
  <li> The session provides a way to store data that will persist between subsequent HTTP requests. This data is associated with a specific user by storing a cookie in their browser. In Sinatra, the session data itself is also stored in this cookie, but this is configurable and not always the case with other web frameworks.</li>
  <li>Data that is submitted to the server often needs to be validated to ensure it meets the requirements of the application. In this lesson we built server-side validation as we performed the validation logic on the server.</li>
  <li>Messages that need to be displayed to the user on their next request and then deleted can be stored in the session. This kind of message is often referred to as a flash message.</li>
  <li>Content from within a view template can be stored under a name and retrieved later using content_for and yield_content.
GET requests should only request data. Any request that modifies data should be over POST or another non-GET method.</li>
  <li>Web browsers don't support request methods other than GET or POST in HTML forms, so there are times when a developer has to use POST even when another method would be more appropriate.</li>
<li>View helpers provide a way to extract code that determines what HTML markup is generated for a view.</li>
