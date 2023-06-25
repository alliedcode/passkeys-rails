module FileManager
  # :reek:UtilityFunction
  def routes_file
    Rails.root.join("config/routes.rb")
  end

  # :reek:UtilityFunction
  def config_file
    Rails.root.join("config/initializers/mobile_pass.rb")
  end

  def remove_config_file
    FileUtils.remove_file config_file if File.file?(config_file)
  end
end
