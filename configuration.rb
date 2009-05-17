class Configuration
  
  def self.read_config
    configHash = {}
    config = self.get_config_file
    
    if File.exists?(config)
      f = File.open(config)
      begin
        while (line = f.readline)
          configHash = self.readline_into_hash(configHash, line)
        end  
      rescue EOFError
        f.close
      end     
    end
    configHash  
  end
  
  def self.get_config_file
    config = File.expand_path(File.join(File.dirname(__FILE__), 'config.app'))
  end
  
  def self.readline_into_hash(hash, line)
    pair = line.split(':')
    if pair.size > 0 
      hash[pair[0].strip] = pair[1].strip;
    end
    hash
  end  
  
end