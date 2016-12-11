require 'rails_helper'

describe AdminsHelper do
        fixtures :users
        fixtures :groups
        fixtures :fullquestions
        before(:each) do
          #Group operations    
          User.find_by_id(1).groups << Group.find_by_id(1)
          User.find_by_id(2).groups << Group.find_by_id(2)
          User.find_by_id(3).groups << Group.find_by_id(3)
          #Question distributions 
          User.find_by_id(1).fullquestions << Fullquestion.find_by_id(3)
          User.find_by_id(2).fullquestions << Fullquestion.find_by_id(3)
          User.find_by_id(3).fullquestions << Fullquestion.find_by_id(3)
        end
    #Test .find_conditional_user
    it ' ' do
        session[:query] = nil
        session[:order] = nil
        #debugger
        expect(helper.find_conditional_users.count).to eq(4)
    end
    it ' ' do
        session[:query] = 'test1@gmail.com'
        session[:order] = nil   
        expect(helper.find_conditional_users.count).to eq(1)
    end
    it ' ' do
        session[:query] = 'test1@gmail.com'
        session[:order] = ["id",true]   
        expect(helper.find_conditional_users.count).to eq(1)
    end
    
    
    it ' ' do
        #debugger
        session[:query] = nil
        session[:order] = ["sub",false]    
        expect(helper.find_conditional_users.count.length).to eq(3)
    end
    it ' ' do
        session[:query] = nil
        session[:order] = ["correct",false]    
        expect(helper.find_conditional_users.count).to eq(4)
    end
    it ' ' do
        session[:query] = nil
        session[:order] = ["accuracy",false]    
        expect(helper.find_conditional_users.count).to eq(4)
    end

    
end