"""Stories router integration tests."""

from __future__ import annotations

import pytest


@pytest.mark.asyncio
async def test_create_story_returns_id(signed_up_client):
    response = await signed_up_client.post("/stories", json={})
    assert response.status_code == 201
    body = response.json()
    assert "id" in body
    assert body["name"] == "Story"


@pytest.mark.asyncio
async def test_create_unauthenticated_returns_401(client):
    response = await client.post("/stories", json={})
    assert response.status_code == 401


@pytest.mark.asyncio
async def test_list_returns_only_callers_stories(signed_up_client):
    await signed_up_client.post("/stories", json={"name": "A"})
    await signed_up_client.post("/stories", json={"name": "B"})
    response = await signed_up_client.get("/stories")
    assert response.status_code == 200
    body = response.json()
    assert len(body) == 2
    names = {item["name"] for item in body}
    assert names == {"A", "B"}


@pytest.mark.asyncio
async def test_get_by_id_returns_full_story(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    response = await signed_up_client.get(f"/stories/{created['id']}")
    assert response.status_code == 200
    body = response.json()
    assert body["id"] == created["id"]
    assert "graph" in body


@pytest.mark.asyncio
async def test_get_by_id_unknown_returns_404(signed_up_client):
    response = await signed_up_client.get("/stories/does-not-exist")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_rename_story(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    response = await signed_up_client.patch(
        f"/stories/{created['id']}", json={"name": "Renamed"}
    )
    assert response.status_code == 200
    assert response.json()["name"] == "Renamed"


@pytest.mark.asyncio
async def test_rename_with_empty_name_returns_422(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    response = await signed_up_client.patch(
        f"/stories/{created['id']}", json={"name": ""}
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_save_graph(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    body = {
        "graph": {
            "nodes": [
                {
                    "nodeId": 0,
                    "data": "Once upon a time",
                    "childrenIds": [],
                    "isEnding": False,
                    "type": "narrative",
                }
            ]
        }
    }
    response = await signed_up_client.put(
        f"/stories/{created['id']}/graph", json=body
    )
    assert response.status_code == 200


@pytest.mark.asyncio
async def test_save_invalid_graph_returns_422(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    # Duplicate node ids — structural error.
    body = {
        "graph": {
            "nodes": [
                {"nodeId": 0, "data": "a", "childrenIds": [], "isEnding": False, "type": "narrative"},
                {"nodeId": 0, "data": "b", "childrenIds": [], "isEnding": False, "type": "narrative"},
            ]
        }
    }
    response = await signed_up_client.put(
        f"/stories/{created['id']}/graph", json=body
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_delete_story(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    response = await signed_up_client.delete(f"/stories/{created['id']}")
    assert response.status_code == 204
    after = await signed_up_client.get(f"/stories/{created['id']}")
    assert after.status_code == 404


@pytest.mark.asyncio
async def test_delete_unknown_returns_404(signed_up_client):
    response = await signed_up_client.delete("/stories/does-not-exist")
    assert response.status_code == 404


@pytest.mark.asyncio
async def test_export_unsupported_format_returns_422(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    response = await signed_up_client.get(
        f"/stories/{created['id']}/export?format=pdf"
    )
    assert response.status_code == 422


@pytest.mark.asyncio
async def test_export_txt_returns_attachment(signed_up_client):
    created = (await signed_up_client.post("/stories", json={})).json()
    response = await signed_up_client.get(
        f"/stories/{created['id']}/export?format=txt"
    )
    assert response.status_code == 200
    assert response.headers["content-type"].startswith("text/plain")
    assert 'attachment' in response.headers.get("content-disposition", "")


@pytest.mark.asyncio
async def test_export_unauthenticated_returns_401(client):
    response = await client.get("/stories/anything/export?format=txt")
    assert response.status_code == 401
