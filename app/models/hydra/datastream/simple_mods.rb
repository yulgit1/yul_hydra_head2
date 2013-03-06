require 'active_fedora'

# Datastream that uses a Generic MODS Terminology;  essentially an exemplar.
# this class will be renamed to Hydra::Datastream::ModsBasic in Hydra 5.0
# reference
#   https://github.com/projecthydra/solrizer
#   https://github.com/projecthydra/om/blob/master/GETTING_STARTED.textile
#   https://github.com/projecthydra/om/blob/master/COMMON_OM_PATTERNS.textile
#   
module Hydra
  module Datastream
    class SimpleMods < ActiveFedora::NokogiriDatastream       
      	  
      set_terminology do |t|
        t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")

		t.classification(:path=>"classification")
		
		t.name(:path=>"name") {
		  t.namePart(:path=>"namePart") 
		}  
        t.title_info(:path=>"titleInfo") {
          t.main_title(:path=>"title",:attributes=>{:type=>:none})
		  t.alt_title(:path=>"title",:attributes=>{:type=>"alternative"})
        }
        t.isbn(:path=>"identififer",:attributes=>{:type=>"isbn"}) 		
	  end
	  
	  def extract_classifications
        classifications = {}
        self.find_by_terms(:classification).each do |aclass| 
          ::Solrizer::Extractor.insert_solr_field_value(classifications, "classification_s", aclass.text) 
        end
        return classifications
      end
	  
	  def extract_names
        names = {}
        self.find_by_terms(:name,:namePart).each do |name| 
          ::Solrizer::Extractor.insert_solr_field_value(names, "names_t",name.text) 
        end
        return names
      end
	  
	  def extract_titles
        titles = {}
        self.find_by_terms(:title_info,:main_title).each do |title| 
          ::Solrizer::Extractor.insert_solr_field_value(titles, "main_title_t", title.text) 
        end
        return titles
      end
	  
	  def extract_alt_titles
        titles = {}
        self.find_by_terms(:title_info,:alt_title).each do |title| 
          ::Solrizer::Extractor.insert_solr_field_value(titles, "alt_title_t", title.text) 
        end
        return titles
      end
	  
	  def extract_isbns
        isbns = {}
        self.find_by_terms(:isbn).each do |isbn| 
          ::Solrizer::Extractor.insert_solr_field_value(isbns, "classification_s", isbn.text) 
        end
        return isbns
      end
	  
	  def to_solr(solr_doc=Hash.new)
          super(solr_doc)
		  solr_doc.merge!(extract_classifications)
		  solr_doc.merge!(extract_names)
          solr_doc.merge!(extract_titles)
		  solr_doc.merge!(extract_alt_titles)
		  solr_doc.merge!(extract_isbns)
          solr_doc.merge!(:object_type_facet => "MODS described")
          solr_doc
        end
    end
  end
end
