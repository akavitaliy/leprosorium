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
	@db.execute 'create table if not exists "Posts" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" date, "content" text, "post_name");'

	@db.execute 'create table if not exists "Comments" ("id" INTEGER PRIMARY KEY AUTOINCREMENT, "created_date" date, "content" text, "post_id" integer, "comment_name" text);'
end

get '/' do
	#выбираем список постов из таблицы Posts
	@results = @db.execute 'select * from Posts order by id DESC'
	erb :index
end

get '/new' do
	erb :new
end

get '/details/:post_id' do	
	# получаем переменную из url
	post_id = params[:post_id]
	#получаем один пост из списка постов
	results = @db.execute 'select * from Posts where id = ?', [post_id]
	
	@row = results[0]
	#получаем коментарии из таблицы Comments для поста
	@comments = @db.execute 'select * from Comments where post_id = ? order by id', [post_id]

	erb :details
	
end


post '/new' do	
	@content = params[:content]
	@post_name = params[:post_name]

	hh ={:post_name => 'Type your name', :content => 'Type post text'}

	hh.each do |key, value|
		if params[key] == ''
			@error = hh[key]
			return erb :new
		end
	end

	# if post_name.length <= 0
	# 	@error = 'Type your name'
	# 	return erb :new
	# end
	
	# if content.length <= 0
	# 	@error = 'Type post text'
	# 	return erb :new
	# end
	#сохранение данных в БД
	@db.execute 'insert into Posts (post_name, content, created_date) values (?,?,datetime())', [@post_name, @content]

	#перенаправляет на главную стр.
	redirect to '/'
	#erb "You type #{content}"
end

post '/details/:id' do
	# получаем переменную из url
	post_id = params[:id]
	#получаем переменную из post запроса
	comment_name = params[:comment_name]
	content = params[:content]

	hh ={:comment_name => 'Type your name', :content => 'Type post text'}

	hh.each do |key, value|
		if params[key] == ''
			@error = hh[key]
			redirect to ('/details/' + post_id)
		end
	end

	@db.execute 'insert into Comments (comment_name, content, created_date, post_id) values (?,?,datetime(),?)', [comment_name, content, post_id]


	redirect to ('/details/' + post_id)

end

