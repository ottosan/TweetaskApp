class BotController < ApplicationController
	@url = "http://..." #サイトurl
	ERRORMSG = "user登録を行って下さい．下記リンクにアクセスし，Twitter認証するだけで登録が完了します．\n#{@url}"
	# add task
	def add(object)
		if(user = User.find_by(screen_name: object.user.screen_name)) 
			# userが既に登録済み
			task = object.text.dup
			task.slice!('@tweetask_app').slice!(/を追加$/)
			p task
			cont = 0
			# tasks.each do |task|
				if task != nil
					Task.create(name: task, user_id: user.id, status: true)
					puts 'create:' + task
					cont = cont + 1
					msg = "taskを#{cont}つ追加しました"
				end
			# end
			
		else # userが登録されていない
			msg = ERRORMSG
		end
		return msg
	end

	# show the tasks
	def show(object)
		if(user = User.find_by(screen_name: object.user.screen_name)) 
			# userが存在
			if Task.exists?(user_id: user.id, status: true)
				tasks = Task.where(user_id: user.id, status: true)
				tasks.each do |task, count|
					added = msg + count + ' ' + task + '\n'
					if added.length > 137 - @url.length
						msg = msg + '...' + @url
						break
					end
					msg = added
				end
			else
				msg = "タスクが登録されていません"
			end
		else 
			msg = ERRORMSG
		end
		return msg
	end

	# delete the tasks
	def delete(object)
		if(user = User.find_by(screen_name: object.user.screen_name)) 
			#userが存在
			if Task.exists?(user_id: user.id, status: true)
				num = object.text.dup.slice!('@tweetask_app').slice!(/を削除$/).to_i
				tasks = Task.where(user_id: user.id, status: true)
				msg = 'タスク'
				# tasknums.each do |num|
					if num < tasks.length
						puts 'destroy: ' + tasks[num]
						tasks[num].destroy
						msg = msg + "#{num}"
					end
				# end
				msg = msg + 'を削除しました．'
			else
				msg = "タスクが存在しません"
			end
		else 
			msg = ERRORMSG
		end
		return msg
	end

	# finish the tasks
	def finish(object)
		if(user = User.find_by(screen_name: object.user.screen_name)) 
			#userが存在
			if Task.exists?(user_id: user.id, status: true)
				num = object.text.dup.slice!('@tweetask_app').slice!(/を完了$/).to_i
				tasks = Task.where(user_id: user.id, status: true)
				msg = 'タスク'
				# tasknums.each do |num|
					if num < tasks.length
						puts 'done: ' + tasks[num]
						tasks[num].update(status: false)
						msg = msg + "#{num} "
					end
				# end
				msg = msg + 'を完了しました．'
			else
				msg = "タスクが存在しません"
			end
		else 
			msg = ERRORMSG
		end
		return msg
	end

	def start
		#キー等の登録
		client_rest = Twitter::REST::Client.new do |config|
		  config.consumer_key        = "Mhy5zoY9neUTBaq0GDjCq5NKc"
		  config.consumer_secret     = "04M5ToXB1yRFwlrave95TMpRKHdZ9hbiZjkthTZ7pm0VXpBQno"
		  config.access_token        = "833944157454413825-iInUb9c0Zf4iQGWycHU6Bo7BtRwC6eD"
		  config.access_token_secret = "u4TFx8VgtZco3BfGpfFiz1RFJA1PAAGEbSSIVmj6vTVMY"
		end
		
		client_stream = Twitter::Streaming::Client.new do |config|
		  config.consumer_key        = "Mhy5zoY9neUTBaq0GDjCq5NKc"
		  config.consumer_secret     = "04M5ToXB1yRFwlrave95TMpRKHdZ9hbiZjkthTZ7pm0VXpBQno"
		  config.access_token        = "833944157454413825-iInUb9c0Zf4iQGWycHU6Bo7BtRwC6eD"
		  config.access_token_secret = "u4TFx8VgtZco3BfGpfFiz1RFJA1PAAGEbSSIVmj6vTVMY"
		end

		# BOTNAME = "tweetask_app"

		client_stream.user do |object|
			case object
			when Twitter::Tweet
				if ((/@tweetask_app/ =~ object.text) && (!object.text.index("RT")) && (object.user.screen_name != 'tweetask_app'))
					option = { 'in_reply_to_status_id' => object.id }
					if /を追加$/ =~ object.text
						reply = add(object)
					elsif /一覧$/ =~ object.text
						reply = show(object)
					elsif /を削除$/ =~ object.text
						reply = delete(object)
					elsif /を完了$/ =~ object.text
						reply = finish(object)
					else
						reply = "こんな風に話しかけてみて下さい\nタスクを追加する場合「買い物を追加」\n一覧を見る場合「一覧」\nタスクを削除する場合「1を削除」\n#{@url}"
					end # end of if
					client_rest.update('@'+object.user.screen_name+' '+reply, option)
				end #end of if
			end # end of case
		end # end of client_stream.user do
	end # end of start
end

