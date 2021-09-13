require 'bundler/setup'
Bundler.require
require 'sinatra/reloader' if development?
require './models'
require 'dotenv/load'
require 'open-uri'
require 'net/http'
require 'json'

enable :sessions

helpers do
    def current_user
        User.find_by(id: session[:user])
    end
    def users
        User.all
    end
    def posts
        Post.all
    end
    def likes
        Like.all
    end
end

before do
    Dotenv.load
    Cloudinary.config do |config|
        config.cloud_name = ENV['CLOUD_NAME']
        config.api_key = ENV['CLOUDINARY_API_KEY']
        config.api_secret = ENV['CLOUDINARY_API_SECRET']
    end
    # @user = User.find_by(id: session[:user])
end

get '/' do
    logger.info @likes
    erb :index
end

get '/signup' do
    erb :sign_up
end

post '/signup' do
    if params[:icon]
        img = params[:icon]
        tempfile = img[:tempfile]
        upload = Cloudinary::Uploader.upload(tempfile.path)
        icon_url = upload['url']
    end
    user = User.create(
        name: params[:name],
        password: params[:password],
        password_confirmation: params[:password_confirmation],
        icon: icon_url
        )
    if user.persisted?
        session[:user] = user.id
    end
    redirect '/'
end

post '/signin' do
    user = User.find_by(name: params[:name])
    if user && user.authenticate(params[:password])
            session[:user] = user.id
    end
    redirect '/'
end

get '/signout' do
    session[:user] = nil
    redirect '/'
end

get '/search' do
    artist = params[:artist]
    uri = URI("https://itunes.apple.com/search")
    uri.query = URI.encode_www_form({term:artist, limit:10})
    res = Net::HTTP.get_response(uri)
    json= JSON.parse(res.body)
    @musics = json["results"]
    erb :search
end

post '/post/new' do
    current_user.posts.create(
        text: params[:text],
        song_icon: params[:song_icon],
        song_artist: params[:song_artist],
        song_album: params[:song_album],
        song_title: params[:song_title],
        song_sample: params[:song_sample]
        )
    redirect '/'
end

get '/post/:id/edit' do
    @post = Post.find(params[:id])
    erb :edit
end

post '/post/:id/update' do
    post = Post.find(params[:id])
    post.text = params[:text]
    post.save
    redirect '/'
end

post '/post/:id/delete' do
    post = Post.find(params[:id])
    post.delete
    redirect '/'
end

get '/home' do
    erb :home
end

post '/like/:id' do
    like = Like.create(
        user_id: current_user.id,
        post_id: params[:id]
        )
    redirect '/'
end