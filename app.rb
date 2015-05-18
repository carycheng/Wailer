require 'rubygems'
require 'sinatra'
require 'boxr'
require 'dotenv'; Dotenv.load(".env")
require 'twilio-ruby'

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

post '/submit' do 

  companyName = params[:company]
  info = params[:info]

  # create new client object
  token_refresh_callback = lambda {|access, refresh, identifier| some_method_that_saves_them(access, refresh)}
  client = Boxr::Client.new(ENV['DEV_TOKEN'], 
    refresh_token: ENV['REFRESH_TOKEN'], 
    client_id: ENV['BOX_CLIENT_ID'], 
    client_secret: ENV['BOX_CLIENT_SECRET'], 
    &token_refresh_callback)
  items = client.folder_items(Boxr::ROOT)

  # Create new company folder
  path = '/Sales/Company-Leads'
  folder = client.folder_from_path(path)
  new_folder = client.create_folder(companyName, folder)

  # create and populate new file
  file = File.open('lead-information.docx', 'w')
  file.puts "Company: #{params[:company]}"
  file.puts "Name: #{params[:name]}"
  file.puts "Email: #{params[:email]}"
  file.puts "Message: #{params[:message]}"
  file.puts "Phone Number: #{params[:phone]}"
  file.puts
  file.puts "SDR Call Notes: "
  file.close

  # upload new file, then remove from local dir
  uploaded_file = client.upload_file('./lead-information.docx', new_folder)
  File.delete('./lead-information.docx')

  # create task for Andy Dufresne
  task = client.create_task(uploaded_file, action: :review, message: "Please review, thanks!", due_at: nil)
  client.create_task_assignment(task, assign_to: "237685143", assign_to_login: nil)

  # Twilio API Call
  account_sid = "AC4c44fc31f1d7446784b3e065f92eb4e6"
  auth_token = "5ad821b20cff339979cd0a9d42e1a05d"
  client = Twilio::REST::Client.new account_sid, auth_token

  from = "+14087695509" # Your Twilio number

  friends = {
# "+16504171570" => "Cary",
# "+18053451948" => "Joann",
#  "+15615122265" => "Austin",
# "+16502797331" => "Matt",
#"+16504501439" => "Jane",
# "+16504171570" => "Cary",
# "+16613404762" => "Jared"
"+18052188632" => "David Lasher",
 "+16504547616" => "ZT"
  }
  friends.each do |key, value|
    client.account.messages.create(
        :from => from,
        :to => key,
        :body => "Hey #{value}, heads up! A new opportunity has submitted a form on the '/emailblast' landing page. Please follow up on this!"
    )
    puts "Sent message to #{value}"
   end

  File.new('views/thank_you.erb').readlines
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
  state = 'security_token%3DKnhMJatFipTAnM0nHlZA'
  oauth_url = Boxr::oauth_url(state, host: "app.box.com", response_type: "code", scope: nil, folder_id: nil, client_id: ENV['BOX_CLIENT_ID'])
  redirect(oauth_url)
end 

get '/login' do 
  params = request.env['rack.request.query_hash']
  oauth2_token = params['code'];

  code = Boxr::get_tokens(oauth2_token, grant_type: "authorization_code", assertion: nil, scope: nil, username: nil, client_id: ENV['BOX_CLIENT_ID'], client_secret: ENV['BOX_CLIENT_SECRET'])
  client = Boxr::Client.new(code.access_token)


  File.new('public/portal.html').readlines
end 


get '/' do
  @notes = Note.all :order => :id.desc
  @title = 'All Notes'
  erb :layout
end

get '/thankyou' do
  File.new('views/thank_you.erb').readlines
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