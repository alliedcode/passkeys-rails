module FileManager
  # :reek:UtilityFunction
  def config_file
    Rails.root.join("config/mobile_pass.rb")
  end

  def remove_config
    FileUtils.remove_file config_file if File.file?(config_file)
  end
end
