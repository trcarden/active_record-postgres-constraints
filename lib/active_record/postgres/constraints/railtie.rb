# frozen_string_literal: true
module ActiveRecord
  module Postgres
    module Constraints
      class Railtie < Rails::Railtie
        initializer 'active_record.postgres.constraints.patch_active_record' do
          ActiveSupport.on_load(:active_record) do
            AR_CAS = ::ActiveRecord::ConnectionAdapters

            begin
              connection = ActiveRecord::Base.connection
              using_pg = connection.class.to_s == "#{AR_CAS}::PostgreSQLAdapter"
              if using_pg
                Rails.logger.info do
                  'Applying Postgres Constraints patches to ActiveRecord'
                end
                AR_CAS::TableDefinition.include TableDefinition
                AR_CAS::PostgreSQLAdapter.include PostgreSQLAdapter
                AR_CAS::AbstractAdapter::SchemaCreation.prepend SchemaCreation

                ::ActiveRecord::Migration::CommandRecorder.include CommandRecorder
                ::ActiveRecord::SchemaDumper.prepend SchemaDumper
              else
                Rails.logger.warn do
                  'Not applying Postgres Constraints patches to ActiveRecord ' \
                  'since the database is not postgres'
                end
              end

            rescue ActiveRecord::NoDatabaseError
              Rails.logger.warn do
                'Not applying Postgres Constraints patches to ActiveRecord ' \
                'because the database does not exist'
              end
            end
          end
        end
      end
    end
  end
end
