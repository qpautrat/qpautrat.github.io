---
layout: post
title: La validation métier dans le modèle, une assurance vie
summary: Une autre façon d'imaginer la validité de son modèle.
tags:
 - php
 - domain model
 - symfony
 - validation
 - ddd
---

Aujourd'hui j'aimerais parler de validation.
Si j'ai envie d'aborder le sujet c'est parce que bien souvent les développeurs ne connaissent qu'une seule façon de faire sans trop se demander si on peut faire autrement.
C'est, selon moi, un peu la faute des frameworks et de leur documentation.

### Prenons l'exemple de Symfony

Le très fameux framework web français est livré par défaut avec le composant [*validator*](https://github.com/symfony/validator).
Il est facile à utiliser et met à disposition un bon nombre de règles par défaut. Je pense que je ne vous apprend rien.

Considérons l'exemple suivant d'une machine à café. Il est possible de configurer le nombre de morceaux de sucre désiré.
Une contrainte métier nous dit que ce nombre ne peut-être qu'un entier supérieur ou égal à 0.

{% highlight php startinline %}
// CofeeMachine.php

use Symfony\Component\Validator\Constraints as Assert;

class CofeeMachine
{
    /**
     * @Assert\Type("integer")
     * @Assert\GreaterThanOrEqual(0)
     */
    private $numberOfSugarLump = 0;

    public function addSugar($numberOfLump)
    {
        $this->numberOfSugarLump = $numberOfLump;
    }
}

// Controller.php
public function addSugarAction(Request $request, CofeeMachine $cofeeMachine)
{
    $cofeeMachine->addSugar($request->request->get('numberOfSugarLump'));

    $validator = $this->get('validator');
    $errors = $validator->validate($cofeeMachine);

    if (count($errors) > 0) {
        return $this->render('cofeeMachine/error.html.twig', array(
            'errors' => $errors,
        ));
    }

    $this->get('doctrine.orm.entity_manager')->flush();

    return $this->render('cofeeMachine/success.html.twig');
}
{% endhighlight %}

À première vue, on pourrait se dire que c'est simple, que cela fonctionne très bien et qu'il n'y a aucune raison de faire autrement.

### Oui mais...

Le problème est l'**état** dans lequel se trouve notre modèle `CofeeMachine`. Si le nombre de morceaux, que l'on récupère depuis l'objet `Request` est négatif notre machine est dans un état qu'on appelle **invalide**, même pour un court laps de temps.

> Oui c'est normal et c'est pour ça qu'on a notre couche de validation, pour s'assurer qu'on ne persiste pas en base de mauvaises données.

me direz-vous.

Que se passe t'il si vous ajoutez des morceaux **après** votre couche de validation ? Vous voyez où je veux en venir.

> Ça n'arrivera jamais, je sais ce que je fais.

Certe, mais si je vous dis que votre équipe technique va être multipliée par 5 durant les prochains mois, que votre *code base* va grossir exponentiellement et donc sa complexité par extension. Si je vous dis que vous allez devoir faire de l'asynchrone, multiplier les sources de données, etc... Même un système de review de code efficace ne sera pas suffisant pour s'assurer de la cohérence de vos données. Et pour peu que vous vous absentez un temps, c'est *la fin des haricots*.


### Remettons la contrainte métier où elle appartient, dans le métier !

{: .center}
![Keep calm and trust your model](/assets/keep-calm-and-trust-your-model.jpg)

Selon moi ([et bien d'autres](http://codebetter.com/gregyoung/2009/05/22/always-valid/)) vos modèles devrait **toujours** être dans un état valide. Vous vous assurez qu'à n'importe quel moment de votre application vous êtes capable d'agir sur une donnée cohérente et vous évitez de créer des effets de bord ingérables dans le futur.

Quand on y pense, c'est une contrainte business. Elle a toute sa place dans notre **domaine métier** non ?! Pourquoi l'exclure et la déléguer à notre couche infrastructure ?

{% highlight php startinline %}
// CofeeMachine.php

// Librarie de validation par Benjamin Eberlei.
use Assert\Assertion;

class CofeeMachine
{
    /**
     * @Assert\Type("integer")
     * @Assert\GreaterThanOrEqual(0)
     */
    private $numberOfSugarLump = 0;

    public function addSugar($numberOfLump)
    {
        Assertion::integer($numberOfLump);
        Assertion::greaterOrEqualThan($numberOfLump, 0);

        $numberOfSugarLump = $numberOfLump;
    }
}
{% endhighlight %}

> Ok mais il y a maintenant deux étapes de validations qui font exactement la même chose, c'est redondant !

Oui et non. Si votre contexte vous force d'informer le client des erreurs qu'il aurait pu faire alors vous pouvez considérer votre validation
comme une couche de présentation, rien de plus. C'est juste une couche qui vous permet de formater simplement vos erreurs dans votre `Response`.

Dans certains contextes, cette couche de présentation sera inutile et vous pourrez même la supprimer purement et simplement (mais ça j'en parlerais dans un autre billet).

### Testabilité

Le plus beau dans tout ça c'est que pouvez maintenant tester unitairement votre validation d'un point de vue métier.
Plus besoin de charger un système de test avec tout un tas de détails d'architecture (client HTTP, base de données, ...).

{% highlight php startinline %}
/**
 * @test
 */
public function it_should_add_a_natural_integer_or_zero_number_of_sugar_lump()
{
    $cofeeMachine = new CofeeMachine();
    $cofeeMachine->addSugar(-1);
    $this->expectException(\InvalidArgumentException::class);
}
{% endhighlight %}

### Conclusion

Mettre de la validation dans le modèle présente de vrais avantages. Cependant ce n'est peut-être pas cécessaire d'en faire aveuglément partout.
Si vous travaillez sur un projet très fortement orienté CRUD, sans beaucoup de logique métier, déléguer la validation à un composant tierce fera l'affaire.
Soyez simplement averti que la complexité d'un projet augmente rapidement et qu'il n'appartient qu'à vous de détecter le moment où les choses se corsent.