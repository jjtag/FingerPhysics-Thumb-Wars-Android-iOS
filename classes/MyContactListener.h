/*
 *  MyContactListener.h
 *  adventures
 *
 *  Created by ikoryakin on 2/5/10.
 *  Copyright 2010 __MyCompanyName__. All rights reserved.
 *
 */

#include <Box2D.h>
#include "Framework.h"
#include "GameScene.h"

class MyContactListener : public b2ContactListener
	{
		GameScene* gameScene;
	public:		
		void SetGameScene(GameScene* gs)
		{
			gameScene = gs;
		}
		
		/// Called when a contact point is added. This includes the geometry
		/// and the forces.
		void Add(const b2ContactPoint* point);
		
		/// Called when a contact point persists. This includes the geometry
		/// and the forces.
		void Persist(const b2ContactPoint* point);
		
		/// Called when a contact point is removed. This includes the last
		/// computed geometry and forces.
		void Remove(const b2ContactPoint* point);
		
		/// Called after a contact point is solved.
		void Result(const b2ContactResult* point);
	};