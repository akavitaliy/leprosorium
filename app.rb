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

	@db.execute 'create table if not exists "Comments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" date, "content" text, "post_id" integer);'
end

get '/' do
	#выбираем список постов из таблицы Posts
	@results = @db.execute 'select * from Posts order by id DESC'
	erb :index
end

get '/new' do
	erb :new
end

get '/details/:id' do	
	# получаем переменную из url
	post_id = params[:id]
	#получаем один пост из списка постов
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	@row = results[0]

	erb :details
end


post '/new' do	
	content = params[:content]

	if content.length <= 0
		@error = 'Type post text'
		return erb :new
	end
	#сохранение данных в БД
	@db.execute 'insert into Posts (content, created_date) values (?,datetime())', [content]

	#перенаправляет на главную стр.
	redirect to '/'
	#erb "You type #{content}"
end

post '/details/:id' do
	# получаем переменную из url
	post_id = params[:id]
	#получаем переменную из post запроса
	content = params[:content]

	@db.execute 'insert into Comments (content, created_date, post_id) values (?,datetime(),?)', [content, post_id]


	erb "You type: #{content} id = #{post_id}"

end

