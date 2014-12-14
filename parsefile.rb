
# {method GET}
# {route person/:id}
# {response 200}
# {
# 	id: 3294,
# 	name: "martin brennan"
# }
# {/response}
# {response 400}
# {
# 	code: 400,
# 	status: 'Bad Request',
# 	message: 'Poor formatting'
# }
# {/response}
# 
# Hello this is the first route
# this gets a single person.
# 
# cool beans!
get "/person/:id" do
	Person.find(params[:id])
end

get "/person" do
	Person.all()
end