class TasksController < ApplicationController
  before_action :set_task, only: %i[ show edit update destroy ]
  
  # GET /tasks or /tasks.json
  def index
    if params[:sort_expired]
      @tasks=Task.all.orderByDeadline
      
    else
      @tasks = Task.all.ordered
    end  
  end
  
  # GET /tasks/1 or /tasks/1.json
  def show
  end
  
  # GET /tasks/new
  def new
    @task = Task.new
  end
  
  # GET /tasks/1/edit
  def edit
  end
  
  # POST /tasks or /tasks.json
  def create
    @task = Task.new(task_params)
    
    respond_to do |format|
      if @task.save
        format.html { redirect_to @task, notice: "Task was successfully created." }
        format.json { render :show, status: :created, location: @task }
      else
        format.html { render :new, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end
  #----------------------
  def search
    session[:search] = {'word' => params[:search_word], 'status' => params[:search_status], 'priority' => params[:search_priority]}
    @tasks = researched.ordered
    @search_word = session[:search]['word']
    render :index
  end
  
  def sort
    @tasks = researched.ordered
    @search_word = session[:search]['word']  if session[:search].present?
    session[:search] = nil
    render :index
  end
  
  
  def researched
    if session[:search].present?
      # If all searches are empty
      if session[:search]['word'].blank? && session[:search]['status'].blank? && session[:search]['priority'].blank?
        Task.kaminari(params[:page])
        
        # The word has been entered
      elsif session[:search]['word'].present?
        # If status, priority were specified
        if session[:search]['status'].present? && session[:search]['priority'].present?
          Task.search_sort(session[:search]['word']).status_sort(session[:search]['status']).priority_sort(session[:search]['priority']).kaminari(params[:page])
          # If only priority and word is specified
        elsif session[:search]['status'].present?
          Task.search_sort(session[:search]['word']).status_sort(session[:search]['status']).kaminari(params[:page])
          #If only priority and word are specified
        elsif session[:search]['priority'].present?
          Task.search_sort(session[:search]['word']).status_sort(session[:search]['priority']).kaminari(params[:page])
        else
          Task.search_sort(session[:search]['word']).kaminari(params[:page])
        end
        
        
        # The word is empty and the status is specified
      elsif session[:search]['status'].present?
        # If priority and status are specified
        if session[:search]['priority'].present?
          Task.status_sort(session[:search]['status']).priority_sort(session[:search]['priority']).kaminari(params[:page])
          # If only priority is specified
        else 
          Task.status_sort(session[:search]['status']).kaminari(params[:page])
        end
        
        # Word, status is empty, and priority is specified
      elsif session[:search]['priority'].present?
        Task.priority_sort(session[:search]['priority']).kaminari(params[:page])
      else
        Tak.kaminari(params[:page])
      end
    end
  end
  
  # PATCH/PUT /tasks/1 or /tasks/1.json
  def update
    respond_to do |format|
      if @task.update(task_params)
        format.html { redirect_to @task, notice: "Task was successfully updated." }
        format.json { render :show, status: :ok, location: @task }
      else
        format.html { render :edit, status: :unprocessable_entity }
        format.json { render json: @task.errors, status: :unprocessable_entity }
      end
    end
  end
  
  # DELETE /tasks/1 or /tasks/1.json
  def destroy
    @task.destroy
    respond_to do |format|
      format.html { redirect_to tasks_url, notice: "Task was successfully destroyed." }
      format.json { head :no_content }
    end
  end
  
  private
  # Use callbacks to share common setup or constraints between actions.
  def set_task
    @task = Task.find(params[:id])
  end
  
  # Only allow a list of trusted parameters through.
  def task_params
    params.require(:task).permit(:title, :detail,:deadline,:priority,:status)
  end
end
