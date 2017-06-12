class HomeController < BaseController
	before_action :move_to_index, except: :index

	def index
		if current_user && Task.exists?(user_id: current_user.id)
			@tasks = Task.where(user_id: current_user.id, status: true)
		end
	end

	def new
	end

	def create
		Task.create(name: task_params[:name], text: task_params[:text], user_id: current_user.id, status: true)
	end

	def edit
		@task = Task.find(params[:id])
	end

	def update
		task = Task.find(params[:id])
		if task.user_id == current_user.id
			task.update(name: task_params[:name], text: task_params[:text])
		end
	end

	def destroy
		task = Task.find(params[:id])
		if task.user_id == current_user.id
			task.destroy
			redirect_to root_path
		end
	end

	def done
		task = Task.find(params[:id])
		if task.user_id == current_user.id
			task.update(status: false)
			redirect_to root_path
		end
	end

	private
	def task_params
		params.permit(:name, :text)
	end

	def move_to_index
		redirect_to action: :index unless current_user
	end
end
