require 'faker'

namespace :db do
  desc "Fill databsae with sample data"
  task :populate => :environment do
    Rake::Task['db:reset'].invoke

    admin = User.create!(:name => "Example User",
                         :email => "example@railstutorial.org",
                         :password => "foobar",
                         :password_confirmation => "foobar").toggle!(:admin)


    99.times do |n|
      name = Faker::Name.name
      email = "example-#{n+1}@railstutorial.org"
      password = "foobar"
      
      User.create!(:name => name,
                   :email => email,
                   :password => password,
                   :password_confirmation => password)
    end
  end
end
