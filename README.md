#  Flickr Previewer

I have structured the project as if it were a larger application to maintain good organization and scalability. The main folders are:

- `Components/` - Contains reusable UI components (only one)
- `Services/` - Contains code for interacting with external services (Flickr API)
- `Views/` - Contains the different views/screens of the application, together with their view models (only one)


A reasonable next step featurewise would be to navigate to a view when selecting a photo
It would also make sense to separate the network layer from the service layer.
