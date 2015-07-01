module Castmaster

  module Database

    def query(sql)
      ActiveRecord::Base.connection.query(sql)
    end

  end

  extend Database

end



