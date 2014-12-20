# {title Person Routes}
module Routes
  class People

    # gets a single person based on their id
    #
    # {method GET}
    # {route /person/:id}
    # {param id integer}
    #   the id of the person to get
    #   uniquely identifies the person
    # {/param}
    # {header X-Custom-Header}
    #   This header is always required for the person route
    #   It always alters the route
    # {/header}
    # {response 200 ok}
    # {
    #   id: 1,
    #   name: 'John Smith',
    #   age: 22
    # }
    # {/response}
    get '/person/:id' do
      Person.find(params[:id])
    end
  end
end