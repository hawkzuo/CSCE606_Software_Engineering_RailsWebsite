require 'rails_helper'

describe DiseasesHelper do
    
    
    #Test .insert!
    
    it '  ' do
        all_data = nil
        expect(helper.insert!(all_data)).to be_nil

    end
    it '  ' do
        all_data = []
        expect(helper.insert!(all_data)).to be_nil
    end  
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
          User.find_by_id(1).fullquestions << Fullquestion.find_by_id(2)
          User.find_by_id(2).fullquestions << Fullquestion.find_by_id(2)
          User.find_by_id(3).fullquestions << Fullquestion.find_by_id(2)
          User.find_by_id(1).fullquestions << Fullquestion.find_by_id(1)
          User.find_by_id(2).fullquestions << Fullquestion.find_by_id(1)
          User.find_by_id(3).fullquestions << Fullquestion.find_by_id(1)

        end    
    it '  ' do
        all_data = [{"user_id"=>2, "fullquestion_id"=>"3", "choice"=>"1", "reason"=>""}]
        expect(helper.insert!(all_data)).to eq(all_data)
    end     
    it '  ' do
        all_data = [{"user_id"=>2, "fullquestion_id"=>"3", "choice"=>"2", "reason"=>""}]
        expect(helper.insert!(all_data)).to eq(all_data)
    end 
    
    it '  ' do
        all_data = [{"user_id"=>2, "fullquestion_id"=>"2", "choice"=>"1", "reason"=>""}]
        expect(helper.insert!(all_data)).to eq(all_data)
    end    
    it '  ' do
        all_data = [{"user_id"=>2, "fullquestion_id"=>"2", "choice"=>"2", "reason"=>""}]
        helper.insert!(all_data)
        all_data2 = [{"user_id"=>2, "fullquestion_id"=>"2", "choice"=>"1", "reason"=>""}]
        expect(helper.insert!(all_data2)).to eq(all_data2)
    end   
    
    it '  ' do
        all_data = [{"user_id"=>2, "fullquestion_id"=>"1", "choice"=>"1", "reason"=>""}]
        helper.insert!(all_data)
        all_data2 = [{"user_id"=>2, "fullquestion_id"=>"1", "choice"=>"2", "reason"=>""}]
        expect(helper.insert!(all_data2)).to eq(all_data2)
    end    
    it '  ' do
        all_data = [{"user_id"=>2, "fullquestion_id"=>"1", "choice"=>"2", "reason"=>""}]
        expect(helper.insert!(all_data)).to eq(all_data)
    end     
end