class TestCasesController < ApplicationController
  include ApplicationHelper

  before_action :authenticate_user!
  before_action :find_test_case, only: [:show, :edit, :update, :destroy, :run]
  before_action :find_question, only: [:index, :new, :create]

  def index
    @test_cases = TestCase.where(question: @question)
  end

  def new
    @test_case = TestCase.new
  end

  def create
    @test_case = @question.test_cases.build(test_case_params)
    if @test_case.save
      flash[:success] = "Caso de teste criado!"
      redirect_to @test_case
    else
      render 'new'
    end
  end

  def show
  end

  def edit
  end

  def update
    if @test_case.update_attributes(test_case_params)
      flash[:success] = "Caso de teste atualizado!"
      redirect_to @test_case
    else
      render 'edit'
    end
  end

  def destroy
    question = @test_case.question
    @test_case.destroy
    flash[:success] = "Caso de teste deletado!"
    redirect_to question_test_cases_url(question)
  end

  def run
    result = @test_case.test(plain_current_datetime, "pas", params[:source_code])
    @results = [ { title: @test_case.title, result: result } ]
    respond_to { |format| format.js }
  end

    private

    def test_case_params
      params.require(:test_case).permit(:description, :input, :output, :question_id)
    end

    def find_test_case
      @test_case = TestCase.find(params[:id])
    end

    def find_question
      @question = Question.find(params[:question_id])
    end
end
