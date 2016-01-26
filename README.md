# monkeylearn-ruby

Official Ruby client for the MonkeyLearn API. Build and consume machine learning models for language processing from your Ruby apps.

Installation
------------

Install with rubygems:

    gem install monkeylearn

Or add this line to your Gemfile

    gem "monkeylearn"

Quick start
-----------

First require and configure the lib:

```ruby
require 'monkeylearn'

# Basic configuration
Monkeylearn.configure do |c|
  c.token = 'INSERT_YOUR_API_TOKEN_HERE'
end
```

Classification:

```ruby
r = Monkeylearn.classifiers.classify('cl_hDDngsX8', ['Hola te va amigo?', 'How are you doing mate?'], sandbox: false)
r.result
# =>  [[{"probability"=>0.461, "label"=>"Spanish"}], [{"probability"=>0.996, "label"=>"English"}]]
```

Extraction:

```ruby
r = Monkeylearn.extractors.extract('ex_y7BPYzNG', ['A panel of Goldman Sachs employees spent a recent Tuesday night at the Columbia University faculty club'])
r.result
# => [[{"relevance"=>"0.962", "count"=>1, "positions_in_text"=>[80], "keyword"=>"University faculty club"}, {"relevance"=>"0.962", "count"=>1, "positions_in_text"=>[43], "keyword"=>"recent Tuesday night"}, {"relevance"=>"0.962", "count"=>1, "positions_in_text"=>[11], "keyword"=>"Goldman Sachs employees"}, {"relevance"=>"0.385", "count"=>1, "positions_in_text"=>[2], "keyword"=>"panel"}]]
```

Pipelines:

```ruby
data = {
  input: [
    { text: "Friendly service, superior room! Loved the high ceiling. Housekeeping service should have been a little better. Excellent breakfast and fitness room." }
  ]
}
r = Monkeylearn.pipelines.run('pi_WNo4z7fJ', data, sandbox: false)
r.result
# => {"result"=>{"sentiment_labels"=>[{"sentiment"=>[{"probability"=>1.0, "label"=>"Good"}], "sentence"=>"Friendly service, superior room!"}, {"sentiment"=>[{"probability"=>1.0, "label"=>"Good"}], "sentence"=>"Loved the high ceiling."}, {"sentiment"=>[{"probability"=>0.5, "label"=>"Bad"}], "sentence"=>"Housekeeping service should have been a little better."}, {"sentiment"=>[{"probability"=>0.912, "label"=>"Good"}], "sentence"=>"Excellent breakfast and fitness room."}]}}
```

Classifiers endpoints example
-----------------------------

Create a new classifier:

```ruby
r = Monkeylearn.classifiers.create('Test API sentiment classifier',
                                   description: 'This is a sentiment classifier created with the monkeylearn ruby API client',
                                   language: 'en')
classifier_id = r.result['result']['classifier']['hashed_id']
```

Get the details from the new classifier and the root category id:

```ruby
r = Monkeylearn.classifiers.detail(classifier_id)
root_category_id = r.result['result']['sandbox_categories'][0]['id']
```

Create two child categories:

```ruby
r = Monkeylearn.classifiers.categories.create(classifier_id, 'Positive', root_category_id)
positive_category_id = r.result['result']['category']['id']

r = Monkeylearn.classifiers.categories.create(classifier_id, 'Negative', root_category_id)
negative_category_id = r.result['result']['category']['id']
```

Upload some samples to each category:

```ruby
samples = [
    ['Nice beatiful', positive_category_id],
    ['awesome excelent', positive_category_id],
    ['Awful bad', negative_category_id],
    ['sad pale', negative_category_id],
    ['happy sad both multilabel', [positive_category_id, negative_category_id]]
]
r = Monkeylearn.classifiers.upload_samples(classifier_id, samples)
```

Train the classifier:

```ruby
Monkeylearn.classifiers.train(classifier_id)
```

Classify using the sandbox:

```ruby
r = Monkeylearn.classifiers.classify(classifier_id, ['Awesome excelence'], sandbox: true)
r.result
# => [[{"probability"=>0.998, "label"=>"Positive"}]]
```

Deploy a live version:

```ruby
Monkeylearn.classifiers.deploy(classifier_id)
```

Classify using the live classifier:

```ruby
r = Monkeylearn.classifiers.classify(classifier_id, ['Awesome excelence'], sandbox: false)
r.result
# => [[{"probability"=>0.998, "label"=>"Positive"}]]
```

Edit a category, rename and move the negative category:

```ruby
r = Monkeylearn.classifiers.categories.edit(classifier_id, negative_category_id, 'Positive child', positive_category_id)
```

Delete a category:

```ruby
r = Monkeylearn.classifiers.categories.delete(classifier_id, negative_category_id)
```

Delete the classifier:

```ruby
r = Monkeylearn.classifiers.delete(classifier_id)
```
