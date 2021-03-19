#encoding: utf-8
require 'rubygems'
require 'sinatra'
require 'sqlite3'
require 'sinatra/contrib'


def init_db
	@db = SQLite3::Database.new 'leprosorium.db'
	@db.results_as_hash = true
end

#определяется во всех запросах
before do
	#инициализация БД
	init_db
end

#вызывается каждый раз при инициализации приложения/перезапуска приложения
configure do	
	init_db
	#создаёт таблицу если таблица не существует
	@db.execute 'create table if not exists "Posts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" date, "content" text);'
end

get '/' do
	erb "Hello! <a href=\"https://github.com/bootstrap-ruby/sinatra-bootstrap\">Original</a> pattern has been modified for <a href=\"http://rubyschool.us/\">Ruby School!!!</a>"			
end

get '/new' do
	erb :new
end

post '/new' do	
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end

	erb "You type #{content}"
end

