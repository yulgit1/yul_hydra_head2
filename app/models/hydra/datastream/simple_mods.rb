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

		
		t.accession_number(:path=>"identifier",:attributes=>{:type=>"Accession number"})
		t.related_item(:path=>"relatedItem",:attributes=>{:type=>:none}) {
		  t.part(:path=>"part") {
		    t.detail_box(:path=>"detail",:attributes=>{:type=>"box"}) {
			  t.caption_box(:path=>"caption")
			}
			t.detail_folder(:path=>"detail",:attributes=>{:type=>"folder"}) {
			  t.caption_folder(:path=>"caption")
			}
		  }
		  t.r_i_orbis(:path=>"identifier",:attributes=>{:displayLabel=>"Link to Orbis record"})
		  t.r_i_orbis_barcode(:path=>"identifier",:attributes=>{:displayLabel=>"Orbis barcode"})
		  t.r_i_finding_aid(:path=>"identifier",:attributes=>{:displayLabel=>"Link to Finding Aid"})
		  t.r_i_url(:path=>"url")
		}
		t.related_item_host(:path=>"relatedItem",:attributes=>{:type=>"host"}) {
		  t.r_i_h_name(:path=>"name") {
		    t.r_i_h_namePart(:path=>"namePart")
		  }
          t.r_i_h_title_info(:path=>"titleInfo") {
            t.r_i_h_title(:path=>"title") 
          }
          t.r_i_h_originInfo(:path=>"originInfo") {
            t.r_i_h_place(:path=>"place")
            t.r_i_h_publisher(:path=>"publisher")
            t.r_i_h_dateIssued(:path=>"dateIssued")
            t.r_i_h_edition(:path=>"edition")
          }
          t.r_i_h_note(:path=>"note")
        }
		t.origin_info(:path=>"originInfo") {
		  t.o_i_edition(:path=>"edition") 
		  t.o_i_place(:path=>"place")
		  t.o_i_publisher(:path=>"publisher")
		  t.o_i_dateCreated(:path=>"dateCreated",:attributes=>{:keyDate=>"yes"})
		}
		t.physicalDescription(:path=>"physicalDescription"){
		  t.p_s_note(:path=>"note")
		  t.p_s_form(:path=>"form",:attributes=>{:type=>"material"})
		}
		t.language(:path=>"language") {
		  t.language_term(:path=>"languageTerm",:attributes=>{:type=>"code",:authority=>"iso639-2b"})
		}
		t.record_info(:path=>"recordInfo") {
		  t.language_of_cataloging(:path=>"languageOfCataloging")
		}
		#t.plain_note(:path=>"note",:attributes=>{:type=>:none})
		t.plain_note(:path=>"note",:attributes=>{:displayLabel=>:none})
		#
		t.note_course_info(:path=>"note",:attributes=>{:displayLabel=>"Course Info"})
		t.note_related(:path=>"note",:attributes=>{:displayLabel=>"Related Exhibit or Resource"})
		t.note_job_number(:path=>"note",:attributes=>{:displayLabel=>"Job Number"})
		t.note_citation(:path=>"note",:attributes=>{:displayLabel=>"Citation"})
		#
		t.note_digital(:path=>"note",:attributes=>{:displayLabel=>"Digital"})
				
		t.abstract(:path=>"abstract")
		t.genre(:path=>"genre")
		t.type_of_resource(:path=>"typeOfResource")
		t.location(:path=>"location") {
		  t.phys_loc_yale(:path=>"physicalLocation",:attributes=>{:displayLabel=>"Yale Collection"})
		  t.phys_loc_origin(:path=>"physicalLocation",:attributes=>{:displayLabel=>"Collection of Origin"})
		}  
		t.access_condition(:path=>"accessCondition",:attributes=>{:type=>"useAndReproduction"})
		#
		t.access_condition_restrictions(:path=>"accessCondition",:attributes=>{:type=>"restrictionsOnAccess"})
		
		#
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
        #
		t.issn(:path=>"identifier",:attributes=>{:type=>"issn"})
		
        t.subject(:path=>"subject",:attributes=>{:displayLabel=>:none}) {
          t.topic(:path=>"topic")
		  #
		  t.keyDate(:path=>"temporal",:attributes=>{:keyDate=>"yes"})
		  t.s_name(:path=>"name") {
		    t.s_namePart(:path=>"namePart")
		  }
		  t.s_geographic(:path=>"geographic")
		  t.s_geographic_code(:path=>"geographicCode")  
		  t.s_cartographics(:path=>"cartographics") {
		    t.s_scale(:path=>"scale")
			t.s_projection(:path=>"projection")
			t.s_coordinates(:path=>"coordinates")	
          }
		}
		t.s_style(:path=>"subject",:attributes=>{:displayLabel=>"Style"})
		t.s_culture(:path=>"subject",:attributes=>{:displayLabel=>"Culture"})
		#
		t.s_divinity(:path=>"subject",:attributes=>{:displayLabel=>"Divinity Subject"})
		
		t.display_label(:path=>"note",:attributes=>{:displayLabel=>"caption"})			
	  end
	  
	  def extract_accession_number
        extracts = {}
        self.find_by_terms(:accession_number).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "accession_number_s", extract.text) 		  
        end
        return extracts
      end	  
	  def extract_caption_box
        extracts = {}
        self.find_by_terms(:related_item,:part,:detail_box,:caption_box).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "caption_box_display", extract.text) 		  
        end
        return extracts
      end	  
	  def extract_caption_folder
        extracts = {}
        self.find_by_terms(:related_item,:part,:detail_folder,:caption_folder).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "caption_folder_display", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_namePart
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_name,:r_i_h_namePart).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_namePart_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_title
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_title_info,:r_i_h_title).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_title_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_place
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_originInfo,:r_i_h_place).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_place_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_publisher
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_originInfo,:r_i_h_publisher).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_publisher_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_dateIssued
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_originInfo,:r_i_h_dateIssued).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_dateIssued_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_edition
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_originInfo,:r_i_h_edition).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_edition_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_r_i_h_note
        extracts = {}
        self.find_by_terms(:related_item_host,:r_i_h_note).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "r_i_h_note_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_o_i_edition
        extracts = {}
        self.find_by_terms(:mods,:origin_info,:o_i_edition).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "o_i_edition_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_o_i_place
        extracts = {}
        self.find_by_terms(:mods,:origin_info,:o_i_place).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "o_i_place_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_o_i_publisher
        extracts = {}
        self.find_by_terms(:mods,:origin_info,:o_i_publisher).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "o_i_publisher_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_o_i_dateCreated
        extracts = {}
        self.find_by_terms(:origin_info,:o_i_dateCreated).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "o_i_dateCreated_t", extract.text) 		  
        end
        return extracts
      end
	  def extract_keyDate
        extracts = {}
        self.find_by_terms(:subject,:keyDate).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "keyDate_s",extract.text)
		  ::Solrizer::Extractor.insert_solr_field_value(extracts, "keyDate_facet",extract.text) 
        end
        return extracts
      end
	  def extract_p_s_note
        extracts = {}
        self.find_by_terms(:physicalDescription,:p_s_note).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "p_s_note_t",extract.text)
        end
        return extracts
      end
	  def extract_p_s_form
        extracts = {}
        self.find_by_terms(:physicalDescription,:p_s_form).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "p_s_form_t",extract.text)
        end
        return extracts
      end
	  def extract_language_term
        extracts = {}
        self.find_by_terms(:language,:language_term).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "language_term_t",extract.text)
		  ::Solrizer::Extractor.insert_solr_field_value(extracts, "language_term_facet",extract.text)
        end
        return extracts
      end
	  def extract_language_of_cataloging
        extracts = {}
        self.find_by_terms(:record_info,:language_of_cataloging).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "language_of_cataloging_s",extract.text)
        end
        return extracts
      end
	  def extract_note
        extracts = {}
        self.find_by_terms(:mods,:plain_note).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "note_t",extract.text)
        end
        return extracts
      end
	  def extract_abstract
        extracts = {}
        self.find_by_terms(:abstract).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "abstract_t",extract.text)
        end
        return extracts
      end
	  def extract_s_namePart
        extracts = {}
        self.find_by_terms(:subject,:s_name,:s_namePart).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_namePart_t",extract.text)
		  ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_namePart_facet",extract.text)
        end
        return extracts
      end
	  def extract_s_geographic
        extracts = {}
        self.find_by_terms(:subject,:s_geographic).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_geographic_t",extract.text)
		  ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_geographic_facet",extract.text)
        end
        return extracts
      end
	  def extract_s_geographic_code
        extracts = {}
        self.find_by_terms(:subject,:s_geographic_code).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_geographic_code_s",extract.text)
        end
        return extracts
      end
	  def extract_s_geographic_code
        extracts = {}
        self.find_by_terms(:subject,:s_geographic_code).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_geographic_code_s",extract.text)
        end
        return extracts
      end
	  def extract_s_style
        extracts = {}
        self.find_by_terms(:s_style).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_style_t",extract.text)
        end
        return extracts
      end
	  def extract_s_culture
        extracts = {}
        self.find_by_terms(:s_culture).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_culture_t",extract.text)
        end
        return extracts
      end
	  def extract_s_scale
        extracts = {}
        self.find_by_terms(:subject,:s_cartographics,:s_scale).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_scale_s",extract.text)
        end
        return extracts
      end
	  def extract_s_projection
        extracts = {}
        self.find_by_terms(:subject,:s_cartographics,:s_projection).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_projections_s",extract.text)
        end
        return extracts
      end
	  def extract_s_coordinates
        extracts = {}
        self.find_by_terms(:subject,:s_cartographics,:s_coordinates).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_coordinates_s",extract.text)
        end
        return extracts
      end
	  def extract_genre
        extracts = {}
        self.find_by_terms(:genre).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "genre_t",extract.text)
        end
        return extracts
      end
	  def extract_type_of_resource
        extracts = {}
        self.find_by_terms(:type_of_resource).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "type_of_resource_t",extract.text)
		  ::Solrizer::Extractor.insert_solr_field_value(extracts, "type_of_resource_facet",extract.text)
        end
        return extracts
      end
	  def extract_phys_loc_yale
        extracts = {}
        self.find_by_terms(:location,:phys_loc_yale).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "phys_loc_yale_s",extract.text)
		  ::Solrizer::Extractor.insert_solr_field_value(extracts, "phys_loc_yale_facet",extract.text)
        end
        return extracts
      end
	  def extract_phys_loc_origin
        extracts = {}
        self.find_by_terms(:location,:phys_loc_origin).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "phys_loc_origin_s",extract.text)
        end
        return extracts
      end
	  def extract_access_condition
        extracts = {}
        self.find_by_terms(:access_condition).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "access_condition_display",extract.text)
        end
        return extracts
      end
	  def extract_r_i_orbis
        extracts = {}
        self.find_by_terms(:related_item,:r_i_orbis).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "orbis_display",extract.text)
        end
        return extracts
      end
	  def extract_r_i_orbis_barcode
        extracts = {}
        self.find_by_terms(:related_item,:r_i_orbis_barcode).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "orbis_barcode_s",extract.text)
        end
        return extracts
      end
	  def extract_r_i_finding_aid
        extracts = {}
        self.find_by_terms(:related_item,:r_i_finding_aid).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "finding_aid_display",extract.text)
        end
        return extracts
      end
	  def extract_r_i_url
        extracts = {}
        self.find_by_terms(:related_item,:r_i_url).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "url_display",extract.text)
        end
        return extracts
      end
	  def extract_note_course_info
        extracts = {}
        self.find_by_terms(:note_course_info).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "note_course_info_t",extract.text)
        end
        return extracts
      end
	  def extract_note_related
        extracts = {}
        self.find_by_terms(:note_related).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "note_related_t",extract.text)
        end
        return extracts
      end
	  def extract_note_job_number
        extracts = {}
        self.find_by_terms(:note_job_number).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "note_job_number_t",extract.text)
        end
        return extracts
      end
	  def extract_note_citation
        extracts = {}
        self.find_by_terms(:note_citation).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "note_citation_t",extract.text)
        end
        return extracts
      end
	  def extract_issn
        extracts = {}
        self.find_by_terms(:issn).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "issn_s",extract.text)
        end
        return extracts
      end
	  def extract_access_condition_restrictions
	    extracts = {}
        self.find_by_terms(:access_condition_restrictions).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "access_condition_restrictions_display",extract.text)
        end
        return extracts
      end
	  def extract_note_digital
	    extracts = {}
        self.find_by_terms(:note_digital).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "note_digital_t",extract.text)
        end
        return extracts
      end
	  def extract_s_divinity
	    extracts = {}
        self.find_by_terms(:s_divinity).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "s_divinity_t",extract.text)
        end
        return extracts
      end
		
	  #
	  def extract_classifications
        extracts = {}
        self.find_by_terms(:classification).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "classification_s", extract.text) 		  
        end
        return extracts
      end
	  
	  def extract_names
        extracts = {}
        self.find_by_terms(:mods,:name,:namePart).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "name_namePart_t",extract.text)
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "name_namePart_facet",extract.text)		  
        end
        return extracts
      end
	  
	  def extract_titles
        extracts = {}
        self.find_by_terms(:mods,:title_info,:main_title).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "main_title_t", extract.text) 
        end
        return extracts
      end
	  
	  def extract_alt_titles
        extracts = {}
        self.find_by_terms(:title_info,:alt_title).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "alt_title_t", extract.text)		  
        end
        return extracts
      end
	  
	  def extract_isbns
        extracts = {}
        self.find_by_terms(:isbn).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "isbn_s", extract.text) 
        end
        return extracts
      end

	  def extract_subjects
        extracts = {}
        self.find_by_terms(:mods,:subject,:topic).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "subject_topic_t",extract.text)
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "subject_topic_facet",extract.text)		  
        end
        return extracts
      end

	  def extract_display_label
        extracts = {}
        self.find_by_terms(:display_label).each do |extract| 
          ::Solrizer::Extractor.insert_solr_field_value(extracts, "display_label_s",extract.text) 		  
        end
        return extracts
      end

	  def to_solr(solr_doc=Hash.new)
        super(solr_doc)
	  	solr_doc.merge!(extract_classifications)
	    solr_doc.merge!(extract_names)
        solr_doc.merge!(extract_titles)
        solr_doc.merge!(extract_alt_titles)
	    solr_doc.merge!(extract_isbns)
		solr_doc.merge!(extract_subjects)
		solr_doc.merge!(extract_display_label)
		#
		solr_doc.merge!(extract_accession_number)
		solr_doc.merge!(extract_caption_box)
		solr_doc.merge!(extract_caption_folder)
		solr_doc.merge!(extract_r_i_h_namePart)
		solr_doc.merge!(extract_r_i_h_title)
		solr_doc.merge!(extract_r_i_h_place)
		solr_doc.merge!(extract_r_i_h_publisher)
		solr_doc.merge!(extract_r_i_h_dateIssued)
		solr_doc.merge!(extract_r_i_h_edition)
		solr_doc.merge!(extract_r_i_h_note)
		solr_doc.merge!(extract_o_i_edition)
		solr_doc.merge!(extract_o_i_place)
		solr_doc.merge!(extract_o_i_publisher)
		solr_doc.merge!(extract_o_i_dateCreated)
		solr_doc.merge!(extract_keyDate)
		solr_doc.merge!(extract_p_s_note)
		solr_doc.merge!(extract_p_s_form)
		solr_doc.merge!(extract_language_term)
		solr_doc.merge!(extract_language_of_cataloging)
		solr_doc.merge!(extract_note)
		solr_doc.merge!(extract_abstract)
		solr_doc.merge!(extract_s_namePart)
		solr_doc.merge!(extract_s_geographic)
		solr_doc.merge!(extract_s_geographic_code)
		solr_doc.merge!(extract_s_style)
		solr_doc.merge!(extract_s_culture)
		solr_doc.merge!(extract_s_scale)
		solr_doc.merge!(extract_s_projection)
		solr_doc.merge!(extract_s_coordinates)
		solr_doc.merge!(extract_genre)
		solr_doc.merge!(extract_type_of_resource)
		solr_doc.merge!(extract_phys_loc_yale)
		solr_doc.merge!(extract_phys_loc_origin)
		solr_doc.merge!(extract_access_condition)
		solr_doc.merge!(extract_r_i_orbis)
		solr_doc.merge!(extract_r_i_orbis_barcode)
		solr_doc.merge!(extract_r_i_finding_aid)
		solr_doc.merge!(extract_r_i_url)
		solr_doc.merge!(extract_note_course_info)
		solr_doc.merge!(extract_note_related)
		solr_doc.merge!(extract_note_job_number)
		solr_doc.merge!(extract_note_citation)
		solr_doc.merge!(extract_issn)
		solr_doc.merge!(extract_access_condition_restrictions)
		solr_doc.merge!(extract_note_digital)
		solr_doc.merge!(extract_s_divinity)
        #solr_doc.merge!(:object_type_facet => "MODS described")
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
