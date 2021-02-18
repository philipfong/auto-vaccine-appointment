class Log
  @@logger = Logger.new STDOUT
  @@logger.level = Logger::DEBUG
  @@logger.datetime_format = '%Y-%m-%d %H:%M:%S '
  
  def self.info(msg)
    @@logger.info(msg)
  end

  def self.error(msg)
    @@logger.error(msg)
  end
end
