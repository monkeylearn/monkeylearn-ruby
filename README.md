# monkeylearn-ruby

Official Ruby client for the MonkeyLearn API. Build and consume machine learning models for language processing from your Ruby apps.

Installation
---------------

Install with rubygems:

```bash
$ gem install monkeylearn
```

Or add this line to your Gemfile

```bash
$ gem "monkeylearn", "~> 3"
```

Usage
------

First require and configure the lib:

Before making requests to the API you need to set your [account API Key](https://app.monkeylearn.com/main/my-account/tab/api-keys/):

```ruby
require 'monkeylearn'

# Basic configuration
Monkeylearn.configure do |c|
  c.token = 'INSERT_YOUR_API_TOKEN_HERE'
end
```


### Requests

From the Monkeylearn module you can call any endpoint (check the [available endpoints](#available-endpoints) below). For example you can [classify](#classify) a list of texts using the public [Sentiment analysis classifier](https://app.monkeylearn.com/main/classifiers/cl_oJNMkt2V/):


```ruby
classifier_model_id='cl_Jx8qzYJh'
data = [
  'Great hotel with excellent location',
  'This is the worst hotel ever.'
]

response = Monkeylearn.classifiers.classify(classifier_model_id, data)
```

### Responses

The response object returned by every endpoint call is a `MonkeylearnResponse` object. The `body` attribute has the parsed response from the API:

```ruby
puts response.body
# =>  [
# =>      {
# =>          "text" => "Great hotel with excellent location",
# =>          "external_id" => nil,
# =>          "error" => false,
# =>          "classifications" => [
# =>              {
# =>                  "tag_name" => "Positive",
# =>                  "tag_id" => 1994,
# =>                  "confidence" => 0.922,
# =>              }
# =>          ]
# =>      },
# =>      {
# =>          "text" => "This is the worst hotel ever.",
# =>          "external_id" => nil,
# =>          "error" => false,
# =>          "classifications" => [
# =>              {
# =>                  "tag_name" => "Negative",
# =>                  "tag_id" => 1941,
# =>                  "confidence" => 0.911,
# =>              }
# =>          ]
# =>      }
# =>  ]
```

You can also access other attributes in the response object to get information about the queries used or available:

```ruby
puts response.plan_queries_allowed
# =>  300

puts response.plan_queries_remaining
# =>  240

puts response.request_queries_used
# =>  2
```

### Errors

Endpoint calls may raise exceptions. Here is an example on how to handle them:

```ruby
begin
  response = Monkeylearn.classifiers.classify("[MODEL_ID]", ["My text"])
rescue PlanQueryLimitError => d
  puts "#{d.error_code}: #{d.detail}"
end
```

Available exceptions:

| class                       | Description |
|-----------------------------|-------------|
| `MonkeylearnError`          | Base class for each exception below.                                  |
| `RequestParamsError`        | An invalid parameter was send. Check the exception message or response object for more information. |
| `AuthenticationError`       | Authentication failed, usually because an invalid token was provided. For more information, check the exception message. More about [Authentication](https://monkeylearn.com/api/v3/#authentication). |
| `ForbiddenError`            | You don't have permissions to perform the action on the given resource. |
| `ModelLimitError`           | You have reached the custom model limit for your plan. |
| `ModelNotFound`             | The model does not exist, check the `model_id`. |
| `TagNotFound`               | The tag does not exist, check the `tag_id` parameter. |
| `PlanQueryLimitError`       | You have reached the monthly query limit for your plan. Consider upgrading your plan. More about [Plan query limits](https://monkeylearn.com/api/v3/#query-limits). |
| `PlanRateLimitError`        | You have sent too many requests in the last minute. Check the exception detail. More about [Plan rate limit](https://monkeylearn.com/api/v3/#plan-rate-limit). |
| `ConcurrencyRateLimitError` | You have sent too many requests in the last second. Check the exception detail. More about [Concurrency rate limit](https://monkeylearn.com/api/v3/#concurrecy-rate-limit). |
| `ModuleStateError`          | The state of the module is invalid. Check the exception detail. |


Available endpoints
------------------------

These are all the endpoints of the API. For more information about each endpoint, check out the [API documentation](https://monkeylearn.com/api/v3/).

### Classifiers

#### [Classify](https://monkeylearn.com/api/v3/?shell#classify)


```ruby
Monkeylearn.classifiers.classify(model_id, data, options = {})
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`              |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
|*data*              |`Array[String or Hash]`|A list of up to 200 data elements to classify. Each element must be a *String* with the text or a *Hash* with the required `text` key and the text as the value and an optional `external_id` key with a string that will be included in the response.  |
|*options*           |`Hash`             | Extra options, see below.

Extra option parameters:

| Parameter          |Type               |Default               | Description                                               |
|--------------------|-------------------|----------------------|-----------------------------------------------------------|
|*production_model*  |`Boolean`          | `False`              | Indicates if the classifications are performed by the production model. Only use this parameter with *custom models* (not with the public ones). Note that you first need to deploy the production model from the UI model settings or using the [Classifier deploy endpoint](#deploy). |
|*batch_size*        |`Integer`          | `200`                  | Max amount of texts each request will send to Monkeylearn. A number from 1 to 200. |


Example:

```ruby
data = ["First text", {text: "Second text", external_id: "2"}]
response = Monkeylearn.classifiers.classify("[MODEL_ID]", data)
```

<br>

#### [Classifier detail](https://monkeylearn.com/api/v3/?shell#classifier-detail)


```ruby
Monkeylearn.classifiers.detail(model_id)
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`           |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |

Example:

```ruby
response = Monkeylearn.classifiers.detail("[MODEL_ID]")
```

<br>

#### [Create Classifier](https://monkeylearn.com/api/v3/?shell#create-classifier)


```ruby
Monkeylearn.classifiers.create(name, options = {})
```

Parameters:

Parameter | Type     | Description
----------|----------|----------------------------
name      | `String` | The name of the model.
options   | `Hash`   | Extra optional parameters, see below.

Extra option parameters:

| Parameter          |Type               |Default               | Description                                               |
|--------------------|-------------------|----------------------|-----------------------------------------------------------|
description | `String` | `''` | The description of the model.
algorithm | `String` | `'nb'` | The [algorithm](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-changing-the-algorithm) used when training the model. It can either be "nb" or "svm".
language | `String` | `'en'` | The [language](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-language) of the model. Full list of [supported languages](https://monkeylearn.com/api/v3/#classifier-detail).
max_features | `Integer` | `10000` | The [maximum amount of features](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-max-features) used when training the model. Between 10 and 100000.
ngram_range | `Array` | `[1,1]` | Indicates which [N-gram range](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-n-gram-range) used when training the model. A list of two numbers between 1 and 3. The first one indicates the minimum and the second one the maximum N for the N-grams used.
use_stemming | `Boolean`|  `true`| Indicates whether [stemming](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-stemming) is used when training the model.
preprocess_numbers | `Boolean` | `true` | Indicates whether [number preprocessing](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-preprocess-numbers) is done when training the model.
preprocess_social_media | `Boolean` | `false` | Indicates whether [preprocessing for social media](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-social-media-preprocessing-and-regular-expressions) is done when training the model.
normalize_weights | `Boolean` | `true` | Indicates whether [weights will be normalized](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-normalize-weights) when training the model.
stopwords | `Boolean or Array` | `true` | The list of [stopwords](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-filter-stopwords) used when training the model. Use false for no stopwords, true for the default stopwords, or an array of strings for custom stopwords.
whitelist | `Array` | `[]` | The [whitelist](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-whitelist) of words used when training the model.

Example:

```ruby
response = Monkeylearn.classifiers.create("New classifier name", algorithm: "svm", ngram_range: [1, 2])
```

<br>

#### [Edit Classifier](https://monkeylearn.com/api/v3/?shell#edit-classifier)


```ruby
Monkeylearn.classifiers.edit(model_id, options = {})
```

Parameters:

Parameter  |Type     |Description
-----------|---------|-----------
*model_id* |`String` |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
*options*    |`Hash`   |Extra optional parameters, see below.

Extra option parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
name | `String` | The name of the model.
description | `String` | The description of the model.
algorithm | `String` | The [algorithm](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-changing-the-algorithm) used when training the model. It can either be "nb" or "svm".
language | `String` | The [language](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-language) of the model. Full list of [supported languages](https://monkeylearn.com/api/v3/#classifier-detail).
max_features | `Integer` | The [maximum amount of features](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-max-features) used when training the model. Between 10 and 100000.
ngram_range | `Array` | Indicates which [N-gram range](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-n-gram-range) used when training the model. A list of two numbers between 1 and 3. The first one indicates the minimum and the second one the maximum N for the N-grams used.
use_stemming | `Boolean`| Indicates whether [stemming](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-stemming) is used when training the model.
preprocess_numbers | `Boolean` | Indicates whether [number preprocessing](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-preprocess-numbers) is done when training the model.
preprocess_social_media | `Boolean` | Indicates whether [preprocessing for social media](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-social-media-preprocessing-and-regular-expressions) is done when training the model.
normalize_weights | `Boolean` | Indicates whether [weights will be normalized](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-normalize-weights) when training the model.
stopwords | `Boolean or Array` |  The list of [stopwords](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-filter-stopwords) used when training the model. Use false for no stopwords, true for the default stopwords, or an array of strings for custom stopwords.
whitelist | `Array` | The [whitelist](http://help.monkeylearn.com/tips-and-tricks-for-custom-modules/parameters-whitelist) of words used when training the model.

Example:

```ruby
response = Monkeylearn.classifiers.edit("[MODEL_ID]", name: "New classifier name", algorithm: "nb")
```
<br>

#### [Delete classifier](https://monkeylearn.com/api/v3/?shell#delete-classifier)


```ruby
Monkeylearn.classifiers.delete(model_id)
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`              |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |

Example:

```ruby
Monkeylearn.classifiers.delete('[MODEL_ID]')
```

<br>

#### [List Classifiers](https://monkeylearn.com/api/v3/?shell#list-classifiers)


```ruby
Monkeylearn.classifiers.list(page: 1, per_page: 20)
```

Extra option parameters:

|Parameter           |Type               |Default            | Description |
|--------------------|-------------------|-------------------|-------------|
|*page*              |`Integer`          | `1`               | Specifies which page to get.|
|*per_page*          |`Integer`          | `20`              | Specifies how many items to return per page. |

Example:

```ruby
response = Monkeylearn.classifiers.list(page: 1, per_page: 5)
```

<br>

#### [Deploy](https://monkeylearn.com/api/v3/?shell#deploy)


```ruby
Monkeylearn.classifiers.deploy(model_id)
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`           |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |

Example:

```ruby
Monkeylearn.classifiers.deploy('[MODEL_ID]')
```

<br>

#### [Tag detail](https://monkeylearn.com/api/v3/?shell#classify)


```ruby
Monkeylearn.classifiers.tags.detail(model_id, tag_id)
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`           |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
|*tag_id*            |`Integer`          |Tag ID. |

Example:

``` ruby
response = Monkeylearn.classifiers.tags.detail("[MODEL_ID]", 25)
```

<br>

#### [Create tag](https://monkeylearn.com/api/v3/?shell#create-tag)


```ruby
Monkeylearn.classifiers.tags.create(model_id, name, options = {})
```

Parameters:

| Parameter          |Type      | Description                                               |
|--------------------|----------|-----------------------------------------------------------|
|*model_id*          |`String   |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
|*name*              |`String`  |The name of the new tag. |
|*options*           |`Hash`    |Extra optional parameters, see below. |

Extra option parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*parent_id*         |`Integer`              |**DEPRECATED**. The ID of the parent tag.

Example:

```ruby
response = Monkeylearn.classifiers.tags.create("[MODEL_ID]", "Positive")
```

<br>

#### [Edit tag](https://monkeylearn.com/api/v3/?shell#edit-tag)


```ruby
Monkeylearn.classifiers.tags.edit(model_id, tag_id, options = {})
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`           |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
|*tag_id*            |`Integer`          |Tag ID. |
|*options*           |`Hash`             |Extra optional parameters, see below. |

Extra option parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*name*    |`String`  |The new name of the tag. |

Example:

```ruby
response = Monkeylearn.classifiers.tags.edit("[MODEL_ID]", 25, name: "New name")
```

<br>

#### [Delete tag](https://monkeylearn.com/api/v3/?shell#delete-tag)


```ruby
Monkeylearn.classifiers.tags.delete(model_id, tag_id, options = {})
```

Parameters:

| Parameter     |Type               | Description                                               |
|---------------|-------------------|-----------------------------------------------------------|
|*model_id*     |`String`           |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
|*tag_id*       |`Integer`          |Tag ID. |
|*options*      |`Hash`             |Extra optional parameters, see below. |

Extra option parameters:

| Parameter          |Type               |Default               | Description                                               |
|--------------------|-------------------|----------------------|-----------------------------------------------------------|
|*move_data_to*      |`int`              |`nil`                 |An optional tag ID. If provided, training data associated with the tag will be moved to the specified tag before deletion. |

Example:

```ruby
response = Monkeylearn.classifiers.tags.delete("[MODEL_ID]", 25, move_data_to: 20)
```

<br>

#### [Upload training data](https://monkeylearn.com/api/v3/?shell#upload-data)


```ruby
Monkeylearn.classifiers.upload_data(model_id, data)
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`           |Classifier ID. Always starts with `'cl'`, for example `'cl_oJNMkt2V'`. |
|*data*              |`Array[Hash]`      |A list of hashes with the keys described below.

`data` hash keys:

|Key             | Description |
|---------       | ----------- |
|text | A *String* of the text to upload.|
|tags | An optional *Array* of tag ID integers. The text will be tagged with each of these tags.|
|marks | An optional *Array* of *String*. Each one represents a mark that will be associated with the text. Marks will be created if needed.|

Example:

```ruby
response = Monkeylearn.classifiers.upload_data(
  "[MODEL_ID]",
  [{text: "text 1", tags: [15, 20]},
   {text: "text 2", tags: [20]}]
)
```

<br>

### Extractors


#### [Extract](https://monkeylearn.com/api/v3/?shell#extract)


```ruby
Monkeylearn.extractors.extract(model_id, data, options = {})
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`              |Extractor ID. Always starts with `'ex'`, for example `'ex_oJNMkt2V'`. |
|*data*              |`Array[String or Hash]`|A list of up to 200 data elements to extract. Each element must be a *string* with the text or a *dict* with the required `text` key and the text as the value and an optional `external_id` key with a string that will be included in the response.  |
|*options*           |`Hash`             | Extra options, see below.

Extra option parameters:

| Parameter          |Type               |Default               | Description                                               |
|--------------------|-------------------|----------------------|-----------------------------------------------------------|
|*production_model*  |`Boolean`          | `False`              | Indicates if the extractions are performed by the production model. Only use this parameter with *custom models* (not with the public ones). Note that you first need to deploy the production model from the UI model settings or using the [Classifier deploy endpoint](#deploy). |
|*batch_size*        |`Integer`          | 200                  | Max amount of texts each request will send to MonkeyLearn. A number from 1 to 200. |

Example:

```ruby
data = ["First text", {"text": "Second text", "external_id": "2"}]
response = Monkeylearn.extractors.extract("[MODEL_ID]", data)
```

<br>

#### [Extractor detail](https://monkeylearn.com/api/v3/?shell#extractor-detail)


```ruby
Monkeylearn.extractors.detail(model_id)
```

Parameters:

| Parameter          |Type               | Description                                               |
|--------------------|-------------------|-----------------------------------------------------------|
|*model_id*          |`String`           |Extractor ID. Always starts with `'ex'`, for example `'ex_oJNMkt2V'`. |

Example:

```ruby
response = Monkeylearn.extractors.detail("[MODEL_ID]")
```

<br>

#### [List extractors](https://monkeylearn.com/api/v3/?shell#list-extractors)


```ruby
Monkeylearn.extractors.list(options = {})
```

Parameters:

|Parameter           |Type               |Default            | Description |
|--------------------|-------------------|-------------------|-------------|
|*page*              |`Integer`          | `1`               | Specifies which page to get.|
|*per_page*          |`Integer`          | `20`              | Specifies how many items to return per page. |

Example:

```ruby
response = Monkeylearn.extractors.list(page: 2)
```
