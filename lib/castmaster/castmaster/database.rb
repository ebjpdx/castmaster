module Castmaster

  module Database

    def query(sql)
    	begin
        ActiveRecord::Base.connection.query(sql)
      rescue 
        ActiveRecord::Base.connection.verify!
        ActiveRecord::Base.connection.rollback_db_transaction
        ActiveRecord::Base.connection.query(sql)
      end
    end

    def execute(sql)
    	begin
        ActiveRecord::Base.connection.execute(sql)
      rescue 
        ActiveRecord::Base.connection.verify!
        ActiveRecord::Base.connection.rollback_db_transaction
        ActiveRecord::Base.connection.execute(sql)
      end
    end


  end

  extend Database

end



