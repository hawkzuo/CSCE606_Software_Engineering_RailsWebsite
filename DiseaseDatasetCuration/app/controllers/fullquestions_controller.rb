class FullquestionsController < ApplicationController
    include FullquestionsHelper
    include AdminsHelper
    before_action :admin?
    
    def search
        #debugger
        @poweradmin = current_user
    
    
    
    end
    
    def performsearch
        @poweradmin = current_user
        #This func do two things: get result back from API 
        #+ save result to DB[partsearchresult]
        if(params[:search])
            #debugger
            n_keyword = params[:search]
            @previous_record = Partsearchresult.where(:keyword => n_keyword)
            if @previous_record.count > 0
                @new_temp_record = @previous_record.first
                @all_dataset = @previous_record.first.Data_set_results
                @previous_dataset= Dataset.find_by_name(params[:search]).Data_set
                @dataset=Hash.new
                @all_dataset.each do |k,v|
                    if !@previous_dataset.include?(k)
                        @dataset[k]=v
                    end
                end
            else
                @dataset_raw = search_from_arrayexpress(params[:search])
                if(n_keyword != "")
                    @new_temp_record = Partsearchresult.create(keyword: n_keyword, Data_set_results: @dataset_raw)
                    Dataset.create(name: params[:search])
                    @previous_dataset=nil
                else
                    flash[:warning] = "invalid search term"
                    redirect_to full_search_path
                    return  
                end
                dataset_foruse = Hash.new
                @dataset_raw.each do |k,v|
                    dataset_foruse[k] = v
                  if dataset_foruse.length >= 20
                    break
                  end
                end                
                @dataset = dataset_foruse    
            end
        else
            redirect_to full_search_path
            return
        end
        if @dataset==nil||@dataset.empty?
            flash[:warning] = "No more dataset"
            redirect_to full_search_path
            return   
        end
        render 'search'
    end
    
    
    def groupselect
        #debugger
        if (!params.has_key?(:selected_keys))&&(params[:value]!='add_another')
            flash[:warning] = "Please select a Dataset"
            redirect_to full_search_path
            return
        else
            if params[:selected_keys]=='from_managedata'
                @show_selected_datasets = Hash.new
                @all_questions = Hash.new
                @selected_accession_keys=[params[:accession]]
                @temp_record=0
                Fullquestion.all.each do |q|
                    if q.ds_accession==params[:accession]
                        if !@show_selected_datasets.has_key?(params[:accession])
                            @show_selected_datasets[params[:accession]]=q.ds_name
                        end
                        if !@all_questions.has_key?(q.qcontent)
                            @all_questions[q.qcontent]=q.qanswer
                        end 
                    end
                end
            elsif params[:selected_keys]=='from_anotherquestion'
                @show_selected_datasets = Hash.new
                @all_questions = Hash.new
                @selected_accession_keys=params[:accession]
                @temp_record=0
                Fullquestion.all.each do |q|
                    if @selected_accession_keys.include?(q.ds_accession)
                        if !@show_selected_datasets.has_key?(q.ds_accession)
                            @show_selected_datasets[q.ds_accession]=q.ds_name
                        end
                        if !@all_questions.has_key?(q.qcontent)
                            @all_questions[q.qcontent]=q.qanswer
                        end
                    end
                end
            else
                #Receive primary params
                @selected_accession_keys = params[:selected_keys]
                temp_record_id = params[:user][:temppsr_id]
                @temp_record = Partsearchresult.find(temp_record_id)
             
                if(!@temp_record)
                    redirect_to full_search_path
                    return
                end
                dataset=Dataset.find_by_id(temp_record_id.to_i)
                @datasets=dataset.Data_set
                if (dataset.Data_set==nil)||(dataset.Data_set.empty?)
                    dataset.Data_set=params[:selected_keys]
                else
                    # didn't test this part
                    dataset.Data_set.concat(params[:selected_keys])
                    dataset.Data_set=dataset.Data_set.uniq
                end
                dataset.save!
            
                # save and return back           
                if params[:commit]=='save_back'
    ## how to save here
    
    
    
                    @selected_accession_keys.each do |k|
                        new_fullquestion = Fullquestion.create!(:qcontent => "",
                            :qanswer => "", :ds_accession => k, 
                            :ds_name =>  @temp_record.Data_set_results[k])
                        assign_question_to_group_users(new_fullquestion.id,nil)
                    end
                    redirect_to '/profile'
                    return
                end
            
                #For View Use
  #              @show_selected_keyword  = @temp_record.keyword
                @show_selected_datasets = Hash.new
            
                @selected_accession_keys.each do |key|
                    @show_selected_datasets[key] = @temp_record.Data_set_results[key]
                end
                @temp_record=@temp_record.id
            end
            #Display groups
            if !current_user.group_admin?      #main admin
                @all_groups = Group.all
            else 
                @all_groups = Group.where("admin_uid = ?", current_user.id)
            end            
             #Questions
            @poweradmin = current_user
            @ans = ['Yes','No','Not Given']
            @full_question = Fullquestion.new
            
        end
    end
    
    
    def create
        
        #Two things to do:
        #First save a fullquestion to the DB
        #Two fields on question
        question_desc = params[:qcontent]
        question_ans  = params[:selected_ans].first
        #One about the Group
        selected_grp_ids = params[:selected_grp_ids]
        
        if params[:fullquestion][:temppsr_id]!="0"
            #Two on Dataset
            concerned_dataset_keys = params[:fullquestion][:sakeys].split(' ')
            partsearchresult = Partsearchresult.find(params[:fullquestion][:temppsr_id])
            #Now Create them:
            @accession=concerned_dataset_keys
            concerned_dataset_keys.each do |dataset_accession|
                dataset_name = partsearchresult.Data_set_results[dataset_accession]
                new_fullquestion = Fullquestion.create!(:qcontent => question_desc,
                            :qanswer => question_ans, :ds_accession => dataset_accession, 
                            :ds_name => dataset_name)
            #Second create submissions and assign them to users of different groups
                assign_question_to_group_users(new_fullquestion.id,selected_grp_ids)  
            end
        else # add_another
            if params[:fullquestion][:sakeys].kind_of?(Array)
                @accession = params[:fullquestion][:sakeys].split(' ')
                @accession.each do |dataset_accession|
                    Fullquestion.all.each do |q|
                        if q.ds_accession==@accession
                            @dataset_name=q.ds_name
                            break
                        end
                    end
                    new_fullquestion = Fullquestion.create!(:qcontent => question_desc,
                            :qanswer => question_ans, :ds_accession => dataset_accession, 
                            :ds_name => dataset_name)
            #Second create submissions and assign them to users of different groups
                    assign_question_to_group_users(new_fullquestion.id,selected_grp_ids)  
                end
            else
               @accession = params[:fullquestion][:sakeys]
                Fullquestion.all.each do |q|
                    if q.ds_accession==@accession
                        @dataset_name=q.ds_name
                        break
                    end
                end
                new_fullquestion = Fullquestion.create!(:qcontent => question_desc,
                :qanswer => question_ans, :ds_accession => @accession, :ds_name => @dataset_name)
                #Second create submissions and assign them to users of different groups
                assign_question_to_group_users(new_fullquestion.id,selected_grp_ids)
            end
        end
        if params[:commit]=='add_another'
            redirect_to full_group_path(:accession => @accession, :selected_keys => 'from_anotherquestion')
            return
        end
            redirect_to '/profile'

    end
    
    def index
        #debugger
        @accession=params[:accession]
        @fullquestions=Array.new
        Fullquestion.all.each do |question|
            if question.ds_accession==@accession
                @fullquestions << question
            end
        end
        
    end
    
    #Add CRUD methods to fullquestions, easy, omitted.
    
    
    
    def show
        #debugger
    end
    

        
    
    private
    
    def assign_question_to_group_users(question_id,group_ids)
        
        group_ids.each do |grp_id|
            
            grp = Group.find(grp_id)
            grp_users = grp.get_users
            
            #user has many fullquestions through submisssions
            grp_users.each do |user|
                
                user.fullquestions << Fullquestion.find(question_id)
                
            end
            
        end
    end
    
    
end