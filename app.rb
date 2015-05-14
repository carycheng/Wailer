require 'rubygems'
require 'sinatra'
require 'boxr'
require 'dotenv'; Dotenv.load(".env")

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

# get '/collab' do
#   client = Boxr::Client.new('u0wucRzbojFzmDQVuHxJ3FK8ngFMVmYZ')
#   collaboration = client.add_collaboration('3536701079', {id: '235248328', type: :user}, :viewer_uploader)
#   # expect(collaboration.accessible_by.id).to eq('235248328')
# end
 
post '/oauth' do
  oauth_url = Boxr::oauth_url(URI.encode_www_form_component('security_token%3DKnhMJatFipTAnM0nHlZA'))
  redirect(oauth_url)
end 

get '/login' do 
  params = request.env['rack.request.query_hash']
  oauth2_token = params['code'];

  code = Boxr::get_tokens(oauth2_token, grant_type: "authorization_code", assertion: nil, scope: nil, username: nil, client_id: ENV['BOX_CLIENT_ID'], client_secret: ENV['BOX_CLIENT_SECRET'])

  client = Boxr::Client.new(code.access_token)

  
end 


get '/' do
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  erb :layout
end

  get '/collab' do
    session[:identity] = params['username']
    token_refresh_callback = lambda {|access, refresh, identifier| some_method_that_saves_them(access, refresh)}
    client = Boxr::Client.new('fw4U4Vn83nQwuTZ88eJ5EI7C0fZqEuN0', 
                            refresh_token: 'F5XkfJDIo8YpfUAabDSLXsOeWjyaUKdLSkIKqjyx9qL9L9i5qCjkxNBsw38qaccX',
                            client_id: '4anv7jyvnf5spcpsotgqzus01dasap4j',
                            client_secret: 'Nf5DamKEz7pVcFiVEWdZs7p7EHPkCXDa',
                            &token_refresh_callback)
    collaboration = client.add_collaboration('3536701079', {login: session[:identity], type: :user}, :viewer)
    File.new('public/portal.html').readlines
  end

get '/Satelite' do
  session[:identity] = params['username']
  token_refresh_callback = lambda {|access, refresh, identifier| some_method_that_saves_them(access, refresh)}
  client = Boxr::Client.new('fw4U4Vn83nQwuTZ88eJ5EI7C0fZqEuN0', 
                          refresh_token: 'F5XkfJDIo8YpfUAabDSLXsOeWjyaUKdLSkIKqjyx9qL9L9i5qCjkxNBsw38qaccX',
                          client_id: '4anv7jyvnf5spcpsotgqzus01dasap4j',
                          client_secret: 'Nf5DamKEz7pVcFiVEWdZs7p7EHPkCXDa',
                          &token_refresh_callback)
  collaboration = client.add_collaboration('3551269279', {login: session[:identity], type: :user}, :viewer)
  File.new('public/satelite_portal.html').readlines
end

get '/Telco' do
  session[:identity] = params['username']
  token_refresh_callback = lambda {|access, refresh, identifier| some_method_that_saves_them(access, refresh)}
  client = Boxr::Client.new('fw4U4Vn83nQwuTZ88eJ5EI7C0fZqEuN0', 
                          refresh_token: 'F5XkfJDIo8YpfUAabDSLXsOeWjyaUKdLSkIKqjyx9qL9L9i5qCjkxNBsw38qaccX',
                          client_id: '4anv7jyvnf5spcpsotgqzus01dasap4j',
                          client_secret: 'Nf5DamKEz7pVcFiVEWdZs7p7EHPkCXDa',
                          &token_refresh_callback)
  collaboration = client.add_collaboration('3551271557', {login: session[:identity], type: :user}, :viewer)
  File.new('public/telco_portal.html').readlines
end