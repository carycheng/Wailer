require 'rubygems'
require 'sinatra'
require 'boxr'

configure do
  enable :sessions
end

helpers do
  def username
    session[:identity] ? session[:identity] : 'Hello stranger'
  end
end

before '/secure/*' do
  unless session[:identity]
    session[:previous_url] = request.path
    @error = 'Sorry, you need to be logged in to visit ' + request.path
    halt erb(:login_form)
  end
end

get '/' do
  erb 'Can you handle a <a href="/secure/place">secret</a>?'
end

get '/login/form' do
  erb :login_form
end

post '/login/attempt' do
  session[:identity] = params['username']
  where_user_came_from = session[:previous_url] || '/'
  redirect to where_user_came_from
end

get '/logout' do
  session.delete(:identity)
  erb "<div class='alert alert-message'>Logged out</div>"
end

get '/secure/place' do
  erb 'This is a secret place that only <%=session[:identity]%> has access to!'
end

get '/collab' do
  client = Boxr::Client.new('u0wucRzbojFzmDQVuHxJ3FK8ngFMVmYZ')
  collaboration = client.add_collaboration('3536701079', {id: '235248328', type: :user}, :viewer_uploader)
  # expect(collaboration.accessible_by.id).to eq('235248328')
end
