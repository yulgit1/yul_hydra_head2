class CompoundParent < ActiveFedora::Base
  has_metadata :name => 'descMetadata', :type => Hydra::Datastream::ModsGenericContent
  has_metadata :name => 'accessMetadata', :type => Hydra::Datastream::AccessConditions
  has_metadata :name => 'rightsMetadata', :type => Hydra::Datastream::Rights
  #has_metadata :name => 'descMetadata', :type => ActiveFedora::Datastream
  #has_metadata :name => 'descMetadata', :type => Hydra::Datastream::ModsYulContent
  #has_metadata :name => 'descMetadata', :type => ActiveFedora::MetadataDatastream do |m|
  #  m.field 'title', :string
  #end	
end