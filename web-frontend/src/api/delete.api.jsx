export const deleteItem = async (id) => {
    try{

        const server = `${import.meta.env.VITE_SERVER_URL}/deleteItem/${id}`

        const response = await fetch(server,{
            method:'DELETE',
            credentials:'include'
        })
        if(!response.ok){
            const res = await response.json()
            throw new Error(res.message)
        }
        const res = await response.json()
        return res

    }catch(err){
        throw err
    }
}