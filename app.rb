require 'sinatra'
require 'nokogiri'
require 'open-uri'
require 'rest-client'
require 'mechanize'


client = Mechanize.new


post '/funding_status' do 

@projects = []
successful_projects = []

def find_project(project_name)
	return if project_title == project_name
end



1.upto(10) do |page_number| 
	client.get("https://www.backerkit.com/backertracker?page=#{page_number}") do |page|

	document = Nokogiri::HTML::Document.parse(page.body)
	@project = document.css("div.project-detail")
	project_title = document.css('div.project-title').css('a').text


	@project.each do |project|
	 @projects << [[project.css("div.project-title").css('a')], 
	 	[project.css("ul.project-stats").css('li.pledged_amount').css('strong').text],
	 	[project.css("ul.project-stats").css('li.funding_percentage').css('strong').text]]

		end
	end
end

@project.each do |project| 
	if project.css("ul.project-stats").css('li.funding_percentage').css('strong').text.to_i >= 100
		successful_projects << [[project.css('div.project-title').css('a').text],
								[project.css('div.project-title').css('a').map {|link| link['href']}].reduce(:+),
								[project.css('ul.project-stats').css('li.pledged_amount').css('strong').text],
								[project.css('ul.project-stats').css('li.funding_percentage').css('strong').text]
							   ]


	end
end

 project_hash = []
 successful_projects.each {|project| project_hash << {'title': project[0],
 	'link': project[1],                                                       
 	'amount': project[2], 
 	'funding percentage': project[3]
 		}}


puts project_hash

  successful_projects.each do |project| 
	 RestClient.post "https://hooks.slack.com/services/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", "{
    'attachments': [
        {
          
            'text': '#{project[0].reduce(:+)} ' ,
            'fields': [
                {
                    'title': 'Info: ',
                    'value': ' <https://www.backerkit.com/#{project[1].reduce(:+)}>',
                    'short': true
                },

                {
                	'title': 'Funding Deets: ',
                	'value': '#{project[2].reduce(:+)} funded at #{project[3].reduce(:+)} of goal',
                	'short': true


                },

               
          
            ],
            'color': '#F35A00'
        }
    ]
}"
	end
	"done"
end

#pass url as param
# timed how many open HS tickets for each person
# @here rewteet this now






