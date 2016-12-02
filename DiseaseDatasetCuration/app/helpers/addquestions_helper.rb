module AddquestionsHelper
  include ApplicationHelper
  require 'yaml'
  require 'net/http'
  require 'json'
  
  def search_from_arrayexpress(keywords)
# Use this for formal version

    url = 'https://www.ebi.ac.uk/arrayexpress/json/v3/experiments?keywords='+keywords;
    uri = URI(url)
    response = Net::HTTP.get(uri)
    data_hash=JSON.parse(response)
    if data_hash["experiments"]["total"]!=0
        data_result=Hash.new
        data_hash["experiments"]["experiment"].each {|value|
        data_result[value["accession"]]=value["name"]
        }
    else  
        data_result=nil
    end
# Use this for debug

    # data_result=Hash.new
    # data_result["E-GEOD-57691"]="Differential gene expression in human abdominal aortic aneurysm and atherosclerosis"
    # data_result["E-MTAB-3175"]="Gene expression study in Positron Emission Tomography (PET) positive abdominal aortic aneurysms"
     return data_result
  
  end
end