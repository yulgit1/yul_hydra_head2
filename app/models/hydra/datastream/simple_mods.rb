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
      #include YUL:OM::XML::TerminologyBasedSolrizer      	  
      set_terminology do |t|
        t.root(:path=>"mods", :xmlns=>"http://www.loc.gov/mods/v3", :schema=>"http://www.loc.gov/standards/mods/v3/mods-3-2.xsd")

		t.classification(:path=>"classification")
		
		t.name(:path=>"name") {
		  t.namePart(:path=>"namePart") 
		  #below a test of using TerminologyBasedSolrizer, ERJ prefer to use extract to fine tune this in the model
		  #t.namePart(:path=>"namePart",:index_as=>[:searchable,:displayable]) 
		}
		
        t.title_info(:path=>"titleInfo") {
          t.main_title(:path=>"title",:attributes=>{:type=>:none})
		  t.alt_title(:path=>"title",:attributes=>{:type=>"alternative"})
        }
        t.isbn(:path=>"identifier",:attributes=>{:type=>"isbn"}) 
        
        t.subject(:path=>"subject") {
          t.topic(:path=>"topic")
        }	
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
          ::Solrizer::Extractor.insert_solr_field_value(names, "name_namePart_t",name.text)
          ::Solrizer::Extractor.insert_solr_field_value(names, "name_namePart_display",name.text)		  
        end
        return names
      end
	  
	  def extract_titles
        titles = {}
        self.find_by_terms(:title_info,:main_title).each do |title| 
          ::Solrizer::Extractor.insert_solr_field_value(titles, "main_title_t", title.text) 
		  ::Solrizer::Extractor.insert_solr_field_value(titles, "main_title_display", title.text)
        end
        return titles
      end
	  
	  def extract_alt_titles
        titles = {}
        self.find_by_terms(:title_info,:alt_title).each do |title| 
          ::Solrizer::Extractor.insert_solr_field_value(titles, "alt_title_t", title.text)
          ::Solrizer::Extractor.insert_solr_field_value(titles, "alt_title_display", title.text)		  
        end
        return titles
      end
	  
	  def extract_isbns
        isbns = {}
        self.find_by_terms(:isbn).each do |isbn| 
          ::Solrizer::Extractor.insert_solr_field_value(isbns, "isbn_s", isbn.text) 
        end
        return isbns
      end

	  def extract_subjects
        names = {}
        self.find_by_terms(:subject,:topic).each do |name| 
          ::Solrizer::Extractor.insert_solr_field_value(names, "subject_topic_t",name.text)
          ::Solrizer::Extractor.insert_solr_field_value(names, "subject_topic_display",name.text)
          ::Solrizer::Extractor.insert_solr_field_value(names, "subject_topic_facet",name.text)		  
        end
        return names
      end
	  

	  def to_solr(solr_doc=Hash.new)
        super(solr_doc)
	  	solr_doc.merge!(extract_classifications)
	    solr_doc.merge!(extract_names)
        solr_doc.merge!(extract_titles)
        solr_doc.merge!(extract_alt_titles)
	    solr_doc.merge!(extract_isbns)
		solr_doc.merge!(extract_subjects)
        solr_doc.merge!(:object_type_facet => "MODS described")
        solr_doc
      end

#ERJ testing with override of TerminologyBasedSolrizerMethod	  
=begin
      class << self
        def solrize_node(node_value, doc, term_pointer, term, solr_doc = Hash.new, field_mapper = nil, opts = {})
          return solr_doc unless term.index_as && !term.index_as.empty?
		  generic_field_name_base = OM::XML::Terminology.term_generic_name(*term_pointer)
		  create_and_insert_terms(generic_field_name_base, node_value, term.index_as, solr_doc)
		end
      end
=end	  
    end
  end
end
