class DiseasesController < ApplicationController
  include DiseasesHelper
  include SessionsHelper

  def index
    # byebug
    if !logged_in?
      flash[:warning] = "Please Log in!"
      redirect_to root_path
      return
    end

    user = User.find(session[:user_id])
    @questions= Hash.new
    user.fullquestions.each do |q|
      if @questions.has_key?([q.ds_name,q.ds_accession])
        @questions[[q.ds_name,q.ds_accession]] << [q.id, q.qcontent]
      else
        @questions[[q.ds_name,q.ds_accession]]=[[q.id, q.qcontent]]
      end
    end
    
  end

  def import
    # byebug
    user_id = session[:user_id]
  	choose = params[:choose]
    reason = params[:reason]
    if choose == nil
      flash[:warning] = "No answer given!"
      redirect_to '/diseases'
      return
    end
    
    all_data=Array.new
    choose.each do |qid,answer|
      all_data << {"user_id" => user_id, "fullquestion_id" => qid, "choice" => answer, "reason" => reason[qid]}
    end
    p '-------------'
    p all_data
    insert!(all_data)
    flash[:success] = "Successfully submitted."

    redirect_to '/profile'
  end

end
