# frozen_string_literal: true

require 'sinatra'
require 'sinatra/content_for'
require 'sinatra/reloader' if development?
require 'tilt/erubis'

enable :sessions
set :session_secret, 'secret'
set :erb, :escape_html => true

before do
  session[:lists] ||= []
end

helpers do
  def error_for_list_name(name)
    if !(1..100).cover?(name.size)
      'List name must be between 1 and 100 characters.'
    elsif session[:lists].any? { |list| list[:name] == name }
      'List name must be unique.'
    end
  end

  def error_for_todo(name)
    if !(1..100).cover? name.size
      "Todo name must be between 1 and 100 characters."
    end
  end

  def list_complete?(list)
    todos_count(list) > 0 &&
    todos_remaining_count(list) == 0
  end

  def list_class(list)
    "complete" if list_complete?(list)
  end

  def todos_count(list)
    list[:todos].size
  end

  def todos_remaining_count(list)
    list[:todos].select { |todo| !todo[:completed] }.size
  end

  def sort_lists(lists, &block)
    complete_lists, incomplete_lists = lists.partition { |list| list_complete?(list) }

    incomplete_lists.each { |list| yield list, lists.index(list) }
    complete_lists.each { |list| yield list, lists.index(list) }
  end

  def sort_todos(todos, &block)
    complete_todos, incomplete_todos = todos.partition { |todo| todo[:completed] }

    incomplete_todos.each { |todo| yield todo, todos.index(todo) }
    complete_todos.each { |todo| yield todo, todos.index(todo) }
  end

  def load_list(id)
    lists = session[:lists]
    return lists[id] if id < lists.size

    session[:error] = "Sorry, the requested list does not exist."
    redirect '/lists'
  end
end

get '/' do
  redirect '/lists'
end

# View all of the Lists
get '/lists' do
  @lists = session[:lists]
  erb :lists, layout: :layout
end

# Render the new list form
get '/lists/new' do
  erb :new_list, layout: :layout
end

# Get the page that displays the list
get '/lists/:id' do
  @list_id = params[:id].to_i
  @list = load_list(@list_id)
  redirect '/lists' if @list_id >= session[:lists].size
  erb :list, layout: :layout
end

# Pulls Up The Edit Page For Existing Todo List
get '/lists/:id/edit' do
  id = params[:id].to_i
  @list = session[:lists][id]
  erb :edit_list, layout: :layout
end

# Update an exsting list
post "/lists/:id" do
  list_name = params[:list_name].strip
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :edit_list, layout: :layout
  else
    @list[:name] = list_name
    session[:success] = 'The list has been updated.'
    redirect "/lists"
  end
end

# Create a new list
post '/lists' do
  # :list_name is a value from form submission
  list_name = params[:list_name].strip

  error = error_for_list_name(list_name)
  if error
    session[:error] = error
    erb :new_list, layout: :layout
  else
    session[:lists] << { name: list_name, todos: [] }
    session[:success] = 'The List Has Been Created.'
    redirect '/lists'
  end
end

# Delete the todo list
post '/lists/:list_id/destroy' do
  id=params[:id].to_i
  session[:lists].delete_at(id)
  session[:success] = "The list has been deleted"
  redirect '/lists'
end

# Add a new todo to a list
post '/lists/:list_id/todos' do
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  todo_text = params[:todo].strip

  error = error_for_todo(todo_text)
  if error
    session[:error] = error
    erb :list, layout: :layout
  else
    @list[:todos] << { name: todo_text, completed: false }
    session[:success] = 'The todo was added.'
    redirect "/lists/#{@list_id}"
  end
end

# Delete todo from todo list
post "/lists/:list_id/todos/:id/destroy" do
  todo_id = params[:id].to_i
  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  @list[:todos].delete_at todo_id
  session[:success] = "The todo has been deleted."
  redirect "/lists/#{@list_id}"
end

# Update the status of a Todo
post '/lists/:list_id/todos/:id' do
  todo_id = params[:id].to_i
  is_completed = params[:completed] == 'true'

  @list_id = params[:list_id].to_i
  @list = session[:lists][@list_id]
  @list[:todos][todo_id][:completed] = is_completed

  session[:success] = "The todo has been updated."
  redirect "/lists/#{@list_id}"
end

# Mark All Todos As Complete For a List
post "/lists/:id/complete_all" do
  @list_id = params[:id].to_i
  @list = session[:lists][@list_id]

  @list[:todos].each do |todo|
    todo[:completed] = true
  end

  session[:success] = "All Todos Have Been Completed"
  redirect "/lists/#{@list_id}"
end
