module Sword
  module Endpoints
    class MetsToHyacinthEndpoint < Endpoint

      # Some of these can be removed if no need for external access,
      # though in that case specs may need to be updated to access
      # instance var directly instead of through attr_reader
      attr_reader :content_dir
      attr_reader :mets_xml_file
      attr_reader :mets_parser

      # come up with a better name. These are basically the
      # deposited documents contained within the zip file,
      # not counting the mets.xml file
      attr_accessor :payload_filenames

      def initialize(collection, depositor)
        super
        @hyacinth_adapter = Sword::Adapters::HyacinthAdapter.new
        @mets_parser = Sword::Parsers::MetsParser.new
      end

      def ingest_item_into_hyacinth
        # following code could be move into a MetsEndpoint method called something like
        # ingest_item_into_hyacinth
        # BEGIN>>>>>>
        # populated metadata for hyacinth item object and ingest it into hyacinth
        @hyacinth_adapter.hyacinth_project = @collection.hyacinth_project_string_key
        @hyacinth_adapter.deposited_by = @depositor.name
        @hyacinth_adapter.compose_internal_format_item
        # NOTE: ingest_item returns the response from the server, which can be useful
        # for debugging.
        # @ingest_item_response = @hyacinth_adapter.ingest_item
        @hyacinth_adapter.ingest_item
        # puts @ingest_item_response.inspect
        if @hyacinth_adapter.last_ingest_successful?
          @pid_hyacinth_item_object = @hyacinth_adapter.pid_last_ingest
        else
          unless @hyacinth_adapter.no_op_post
            Rails.logger.error("Hyacinth request unsuccessful: " \
                               "hyacinth_response: #{@ingest_item_response.inspect}, " \
                               "hyacinth_response.body: #{@ingest_item_response.body.inspect}")
            raise "Hyacinth request was not successful, please see log"
          end
        end
        # puts "Last ingest successful? #{@hyacinth_adapter.last_ingest_successful?}"
        # puts "Pid of ingested item object is #{@pid_hyacinth_item_object}"

        # <<<<<<END
      end

      # for each deposited document, ingest into hyacinth as child asset of above item
      def ingest_documents_into_hyacinth
        @documents_to_deposit.each do |document_filename|
          # puts '*******************Document************************'
          # puts document_filename
          document_filepath = File.join(@content_dir,document_filename)
          @hyacinth_adapter.ingest_asset(@pid_hyacinth_item_object,
                                         document_filepath)
          # puts @hyacinth_adapter.digital_object_data
        end
      end

      def ingest_mets_xml_file_into_hyacinth(mets_filename = 'mets.xml')
        mets_xml_filepath = File.join(@content_dir,mets_filename)
        @hyacinth_adapter.ingest_asset(@pid_hyacinth_item_object,
                                       mets_xml_filepath)
      end

      def handle_deposit(path_to_contents)
        @content_dir = path_to_contents
        #check existence of mets.xml file
        if File.exist?(File.join(@content_dir,'mets.xml'))
          @mets_xml_file = File.join(@content_dir,'mets.xml')
        else
          raise "mets.xml file missing"
        end
        @mets_parser.parse @mets_xml_file
        @documents_to_deposit = @mets_parser.flocat_xlink_href
      end
    end
  end
end