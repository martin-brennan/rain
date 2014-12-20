# {title Person Routes}
module Routes

  # The People routes are CRUD routes
  # to get information on people as well
  # as creating **new** people.
  class People

    # Gets a single person based on their id
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

    # Adds a new person and returns their id.
    #
    # {method POST}
    # {route /person}
    # {param name string}
    #   The name of the new person to create
    # {/param}
    # {param age integer 0}
    #   The age of the new person (default 0)
    # {/param}
    # {response 201 created}
    # 3904
    # {/response}
    post '/person/:id' do
      Person.create(name: params[:name], age: params[:age])
    end

    # Updates the person's age.
    #
    # {method PUT}
    # {route /person/:id}
    # {param id integer}
    #   The id of the person
    # {/param}
    # {param age integer}
    #   The age of the person
    # {/param}
    put '/person/:id' do
      Person.update(params[:id], age: params[:age])
    end

    # Deletes the person
    #
    # {method DELETE}
    # {route /person/:id}
    # {param id integer}
    #   The id of the person to delete
    # {/param}
    put '/person/:id' do
      Person.create(name: params[:name], age: params[:age])
    end
  end
end